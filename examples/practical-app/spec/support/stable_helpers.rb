# frozen_string_literal: true

# StableHelpers - JavaScript-based element interaction methods
# All polling and retry logic runs in JavaScript for reliability
# Reduces Ruby ↔ JavaScript communication overhead
module StableHelpers
  # Default configuration
  DEFAULT_TIMEOUT = 10
  DEFAULT_INTERVAL = 50 # ms (JavaScript側)

  # Wait for element to be present and stable in DOM using JavaScript polling
  # @param selector [String] CSS selector
  # @param timeout [Integer] Maximum wait time in seconds
  # @return [Capybara::Node::Element] The found element
  def stable_find(selector, timeout: DEFAULT_TIMEOUT, visible: true)
    js_wait_for_element(selector, timeout: timeout, visible: visible)
    find(selector, visible: visible, wait: 1)
  end

  # Find all elements after ensuring DOM stability
  # @param selector [String] CSS selector
  # @param timeout [Integer] Maximum wait time in seconds
  # @return [Array<Capybara::Node::Element>] Found elements
  def stable_all(selector, timeout: DEFAULT_TIMEOUT)
    wait_for_dom_stable(timeout: timeout)
    all(selector, wait: 1)
  end

  # Click element with retry logic
  # Uses Capybara native click with JS fallback for reliability
  # @param selector [String] CSS selector
  # @param timeout [Integer] Maximum wait time in seconds
  def stable_click(selector, timeout: DEFAULT_TIMEOUT)
    escaped_selector = escape_js(selector)
    start_time = Time.now

    loop do
      begin
        # Use Capybara's find with wait, then click
        element = find(selector, wait: 2, visible: true)
        element.click
        # Small delay to allow event processing
        sleep(0.05)
        return true
      rescue Capybara::ElementNotFound, Ferrum::NodeNotFoundError, Ferrum::TimeoutError,
             Capybara::Cuprite::MouseEventFailed => e
        # If native click fails, try JavaScript click
        js_clicked = page.evaluate_script(<<~JS)
          (function() {
            var el = document.querySelector('#{escaped_selector}');
            if (el && el.offsetParent !== null) {
              el.click();
              return true;
            }
            return false;
          })()
        JS
        return true if js_clicked

        elapsed = Time.now - start_time
        raise e if elapsed > timeout
        sleep(DEFAULT_INTERVAL / 1000.0)
      end
    end
  end

  # Set value on input with stability check
  # @param selector [String] CSS selector
  # @param value [String] Value to set
  # @param timeout [Integer] Maximum wait time in seconds
  def stable_set(selector, value, timeout: DEFAULT_TIMEOUT)
    escaped_value = escape_js(value)
    js_retry_action(selector, 'set', value: escaped_value, timeout: timeout)
  end

  # Send keys to element with stability check
  # @param selector [String] CSS selector
  # @param keys [Array] Keys to send
  def stable_send_keys(selector, *keys, timeout: DEFAULT_TIMEOUT)
    element = stable_find(selector, timeout: timeout)
    element.native.send_keys(*keys)
  end

  # Combined set and send_keys for form inputs (common pattern)
  # Uses JavaScript for value setting, Capybara native for key events
  # @param selector [String] CSS selector
  # @param value [String] Value to type
  # @param submit_key [Symbol] Key to send after value (e.g., :enter)
  def stable_input(selector, value, submit_key: nil, timeout: DEFAULT_TIMEOUT)
    escaped_selector = escape_js(selector)
    escaped_value = escape_js(value)
    start_time = Time.now

    loop do
      # Set value via JavaScript for reliability
      result = page.evaluate_script(<<~JS)
        (function() {
          var el = document.querySelector('#{escaped_selector}');
          if (!el || el.offsetParent === null) {
            return { success: false, reason: 'not_found' };
          }

          try {
            el.focus();
            el.value = '#{escaped_value}';
            el.dispatchEvent(new Event('input', { bubbles: true }));
            el.dispatchEvent(new Event('change', { bubbles: true }));

            if (el.value !== '#{escaped_value}') {
              return { success: false, reason: 'value_not_set' };
            }

            return { success: true };
          } catch (e) {
            return { success: false, reason: e.message };
          }
        })()
      JS

      if result && result['success']
        # Use Capybara's native send_keys for Enter key (more reliable with Stimulus)
        if submit_key
          # Small delay to ensure Stimulus has processed the value change
          sleep(0.05)
          element = find(selector)
          element.native.send_keys(submit_key)
        end
        return true
      end

      elapsed = Time.now - start_time
      if elapsed > timeout
        reason = result ? result['reason'] : 'unknown'
        raise Capybara::ElementNotFound, "stable_input failed on '#{selector}': #{reason}"
      end

      sleep(DEFAULT_INTERVAL / 1000.0)
    end
  end

  # Wait for element count to match expected (all polling in JavaScript)
  # @param selector [String] CSS selector
  # @param count [Integer] Expected count
  # @param timeout [Integer] Maximum wait time in seconds
  def wait_for_count(selector, count, timeout: DEFAULT_TIMEOUT)
    escaped_selector = escape_js(selector)
    js_poll_until(
      "document.querySelectorAll('#{escaped_selector}').length === #{count}",
      timeout: timeout,
      error_message: "Expected #{count} elements for '#{selector}'"
    )
  end

  # Wait for element to contain text
  # @param selector [String] CSS selector
  # @param text [String] Text to find
  # @param timeout [Integer] Maximum wait time in seconds
  def wait_for_text(selector, text, timeout: DEFAULT_TIMEOUT)
    escaped_selector = escape_js(selector)
    escaped_text = escape_js(text)
    js_poll_until(
      "(function() { var el = document.querySelector('#{escaped_selector}'); return el && el.textContent.includes('#{escaped_text}'); })()",
      timeout: timeout,
      error_message: "Text '#{text}' not found in '#{selector}'"
    )
  end

  # Wait for element to have specific class
  # @param selector [String] CSS selector
  # @param class_name [String] CSS class name
  # @param timeout [Integer] Maximum wait time in seconds
  def wait_for_class(selector, class_name, timeout: DEFAULT_TIMEOUT)
    escaped_selector = escape_js(selector)
    escaped_class = escape_js(class_name)
    js_poll_until(
      "(function() { var el = document.querySelector('#{escaped_selector}'); return el && el.classList.contains('#{escaped_class}'); })()",
      timeout: timeout,
      error_message: "Class '#{class_name}' not found on '#{selector}'"
    )
  end

  # Wait for element to NOT have specific class
  # @param selector [String] CSS selector
  # @param class_name [String] CSS class name
  # @param timeout [Integer] Maximum wait time in seconds
  def wait_for_no_class(selector, class_name, timeout: DEFAULT_TIMEOUT)
    escaped_selector = escape_js(selector)
    escaped_class = escape_js(class_name)
    js_poll_until(
      "(function() { var el = document.querySelector('#{escaped_selector}'); return el && !el.classList.contains('#{escaped_class}'); })()",
      timeout: timeout,
      error_message: "Class '#{class_name}' still present on '#{selector}'"
    )
  end

  # Wait for checkbox to be checked
  # @param selector [String] CSS selector
  # @param timeout [Integer] Maximum wait time in seconds
  def wait_for_checked(selector, timeout: DEFAULT_TIMEOUT)
    escaped_selector = escape_js(selector)
    js_poll_until(
      "(function() { var el = document.querySelector('#{escaped_selector}'); return el && el.checked === true; })()",
      timeout: timeout,
      error_message: "Checkbox '#{selector}' not checked"
    )
  end

  # Public API for custom JavaScript conditions
  # @param js_condition [String] JavaScript expression that returns true when ready
  # @param timeout [Integer] Maximum wait time in seconds
  def js_wait_for(js_condition, timeout: DEFAULT_TIMEOUT)
    js_poll_until(js_condition, timeout: timeout, error_message: "Condition not met: #{js_condition}")
  end

  # Wait for DOM to be stable (no pending mutations)
  # Uses MutationObserver setup in JS with Ruby-based polling
  # @param timeout [Integer] Maximum wait time in seconds
  # @param stability_time [Integer] Time in ms with no changes to consider stable
  def wait_for_dom_stable(timeout: DEFAULT_TIMEOUT, stability_time: 100)
    # Setup MutationObserver in JavaScript
    page.execute_script(<<~JS)
      window.__domStabilityState = { stable: false, lastChange: Date.now() };
      if (window.__domObserver) window.__domObserver.disconnect();

      window.__domObserver = new MutationObserver(function() {
        window.__domStabilityState.stable = false;
        window.__domStabilityState.lastChange = Date.now();
      });

      window.__domObserver.observe(document.body, {
        childList: true,
        subtree: true,
        attributes: true
      });
    JS

    start_time = Time.now

    # Poll for stability using Ruby loop
    loop do
      result = page.evaluate_script(<<~JS)
        (function() {
          var state = window.__domStabilityState;
          if (!state) return { stable: true };
          var elapsed = Date.now() - state.lastChange;
          return { stable: elapsed >= #{stability_time}, elapsed: elapsed };
        })()
      JS

      if result && result['stable']
        # Cleanup observer
        page.execute_script(<<~JS)
          if (window.__domObserver) {
            window.__domObserver.disconnect();
            delete window.__domObserver;
          }
          delete window.__domStabilityState;
        JS
        return true
      end

      elapsed = Time.now - start_time
      if elapsed > timeout
        # Cleanup observer on timeout
        page.execute_script('if (window.__domObserver) window.__domObserver.disconnect();')
        raise Capybara::ElementNotFound, 'DOM did not stabilize within timeout'
      end

      sleep(DEFAULT_INTERVAL / 1000.0)
    end
  end

  private

  # Wait for element to be present and visible using JavaScript polling
  def js_wait_for_element(selector, timeout:, visible:)
    escaped_selector = escape_js(selector)
    visibility_check = visible ? ' && el.offsetParent !== null' : ''

    js_poll_until(
      "(function() { var el = document.querySelector('#{escaped_selector}'); return el !== null#{visibility_check}; })()",
      timeout: timeout,
      error_message: "Element not found: #{selector}"
    )
  end

  # Wait for input to have specific value
  def wait_for_value(selector, value, timeout:)
    escaped_selector = escape_js(selector)
    escaped_value = escape_js(value)
    js_poll_until(
      "(function() { var el = document.querySelector('#{escaped_selector}'); return el && el.value === '#{escaped_value}'; })()",
      timeout: timeout,
      error_message: "Value '#{value}' not set on '#{selector}'"
    )
  end

  # Core JavaScript polling - all retry logic runs in browser
  # @param js_condition [String] JavaScript expression that returns true when ready
  # @param timeout [Integer] Maximum wait time in seconds
  # @param error_message [String] Error message on timeout
  def js_poll_until(js_condition, timeout:, error_message: nil)
    timeout_ms = timeout * 1000
    error_msg = error_message || "Condition not met: #{js_condition}"

    # Use synchronous polling with Ruby timeout to avoid async script timeout issues
    start_time = Time.now

    loop do
      result = page.evaluate_script(<<~JS)
        (function() {
          try {
            return #{js_condition} ? true : false;
          } catch (e) {
            return false;
          }
        })()
      JS

      return true if result

      elapsed = Time.now - start_time
      if elapsed > timeout
        raise Capybara::ElementNotFound, error_msg
      end

      sleep(DEFAULT_INTERVAL / 1000.0)
    end
  end

  # JavaScript-based action with Ruby retry loop (click, set, etc.)
  # @param selector [String] CSS selector
  # @param action [String] Action to perform ('click', 'set')
  # @param value [String] Value for 'set' action
  # @param timeout [Integer] Maximum wait time in seconds
  def js_retry_action(selector, action, value: nil, timeout: DEFAULT_TIMEOUT)
    escaped_selector = escape_js(selector)
    escaped_value = value ? escape_js(value) : ''
    start_time = Time.now

    loop do
      result = page.evaluate_script(<<~JS)
        (function() {
          var el = document.querySelector('#{escaped_selector}');
          if (!el || el.offsetParent === null) {
            return { success: false, reason: 'not_found' };
          }

          try {
            if ('#{action}' === 'click') {
              el.click();
              return { success: true };
            } else if ('#{action}' === 'set') {
              el.focus();
              el.value = '#{escaped_value}';
              el.dispatchEvent(new Event('input', { bubbles: true }));
              el.dispatchEvent(new Event('change', { bubbles: true }));
              return { success: true };
            } else {
              return { success: false, reason: 'unknown_action' };
            }
          } catch (e) {
            return { success: false, reason: e.message };
          }
        })()
      JS

      return true if result && result['success']

      elapsed = Time.now - start_time
      if elapsed > timeout
        reason = result ? result['reason'] : 'unknown'
        raise Capybara::ElementNotFound, "Action '#{action}' failed on '#{selector}': #{reason}"
      end

      sleep(DEFAULT_INTERVAL / 1000.0)
    end
  end

  # Escape string for JavaScript
  def escape_js(str)
    str.to_s.gsub('\\', '\\\\\\\\').gsub("'", "\\\\'").gsub("\n", '\\n')
  end
end

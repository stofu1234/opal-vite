# backtick_javascript: true

module OpalVite
  module Concerns
    # StimulusHelpers - DSL macros for reducing JavaScript backticks in Stimulus controllers
    #
    # This module provides Ruby-friendly methods for common Stimulus patterns,
    # reducing the need for raw JavaScript backticks.
    #
    # Usage:
    #   class MyController < StimulusController
    #     include StimulusHelpers
    #
    #     def connect
    #       if has_target?(:input)
    #         value = target_value(:input)
    #         target_set_html(:output, "Value: #{value}")
    #       end
    #     end
    #   end
    module StimulusHelpers
      # ===== Target Access Methods =====

      # Check if a Stimulus target exists
      # @param name [Symbol, String] Target name (e.g., :input, :output)
      # @return [Boolean] true if target exists
      def has_target?(name)
        method_name = "has#{camelize(name)}Target"
        `this[#{method_name}]`
      end

      # Get a Stimulus target element
      # @param name [Symbol, String] Target name
      # @return [Element, nil] The target element or nil
      def get_target(name)
        return nil unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}]`
      end

      # Get all Stimulus targets of a type
      # @param name [Symbol, String] Target name
      # @return [Array] Array of target elements
      def get_targets(name)
        method_name = "#{camelize(name, false)}Targets"
        `Array.from(this[#{method_name}] || [])`
      end

      # Get the value of a target (input field)
      # @param name [Symbol, String] Target name
      # @return [String, nil] The target's value
      def target_value(name)
        return nil unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].value`
      end

      # Set the value of a target (input field)
      # @param name [Symbol, String] Target name
      # @param value [String] The value to set
      def target_set_value(name, value)
        return unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].value = #{value}`
      end

      # Get the innerHTML of a target
      # @param name [Symbol, String] Target name
      # @return [String, nil] The target's innerHTML
      def target_html(name)
        return nil unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].innerHTML`
      end

      # Set the innerHTML of a target
      # @param name [Symbol, String] Target name
      # @param html [String] The HTML to set
      def target_set_html(name, html)
        return unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].innerHTML = #{html}`
      end

      # Get the textContent of a target
      # @param name [Symbol, String] Target name
      # @return [String, nil] The target's textContent
      def target_text(name)
        return nil unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].textContent`
      end

      # Set the textContent of a target
      # @param name [Symbol, String] Target name
      # @param text [String] The text to set
      def target_set_text(name, text)
        return unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].textContent = #{text}`
      end

      # Get a data attribute from a target
      # @param name [Symbol, String] Target name
      # @param attr [String] The data attribute name (without 'data-' prefix)
      # @return [String, nil] The attribute value
      def target_data(name, attr)
        return nil unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].getAttribute('data-' + #{attr})`
      end

      # Set a data attribute on a target
      # @param name [Symbol, String] Target name
      # @param attr [String] The data attribute name (without 'data-' prefix)
      # @param value [String] The value to set
      def target_set_data(name, attr, value)
        return unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].setAttribute('data-' + #{attr}, #{value})`
      end

      # Clear a target's value (for input fields)
      # @param name [Symbol, String] Target name
      def target_clear(name)
        target_set_value(name, '')
      end

      # Clear a target's innerHTML
      # @param name [Symbol, String] Target name
      def target_clear_html(name)
        target_set_html(name, '')
      end

      # ===== Target Style Methods =====

      # Set a style property on a target element
      # @param name [Symbol, String] Target name
      # @param property [String] CSS property name (e.g., 'display', 'color')
      # @param value [String] CSS value
      def set_target_style(name, property, value)
        return unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].style[#{property}] = #{value}`
      end

      # Get a style property from a target element
      # @param name [Symbol, String] Target name
      # @param property [String] CSS property name
      # @return [String, nil] The style value
      def get_target_style(name, property)
        return nil unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].style[#{property}]`
      end

      # Show a target element (set display to '')
      # @param name [Symbol, String] Target name
      def show_target(name)
        set_target_style(name, 'display', '')
      end

      # Hide a target element (set display to 'none')
      # @param name [Symbol, String] Target name
      def hide_target(name)
        set_target_style(name, 'display', 'none')
      end

      # Toggle target visibility
      # @param name [Symbol, String] Target name
      def toggle_target_visibility(name)
        current = get_target_style(name, 'display')
        if current == 'none'
          show_target(name)
        else
          hide_target(name)
        end
      end

      # ===== Target Class Methods =====

      # Add a CSS class to a target element
      # @param name [Symbol, String] Target name
      # @param class_name [String] CSS class to add
      def add_target_class(name, class_name)
        return unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].classList.add(#{class_name})`
      end

      # Remove a CSS class from a target element
      # @param name [Symbol, String] Target name
      # @param class_name [String] CSS class to remove
      def remove_target_class(name, class_name)
        return unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].classList.remove(#{class_name})`
      end

      # Toggle a CSS class on a target element
      # @param name [Symbol, String] Target name
      # @param class_name [String] CSS class to toggle
      def toggle_target_class(name, class_name)
        return unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].classList.toggle(#{class_name})`
      end

      # Check if a target has a CSS class
      # @param name [Symbol, String] Target name
      # @param class_name [String] CSS class to check
      # @return [Boolean] true if target has the class
      def has_target_class?(name, class_name)
        return false unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].classList.contains(#{class_name})`
      end

      # ===== Date/Time Methods =====

      # Get current timestamp (milliseconds since epoch)
      # @return [Integer] Current timestamp
      def js_timestamp
        `Date.now()`
      end

      # Get current date as ISO string
      # @return [String] ISO date string
      def js_iso_date
        `new Date().toISOString()`
      end

      # Create a new Date object
      # @param value [String, Integer, nil] Optional value to parse
      # @return [Native] JavaScript Date object
      def js_date(value = nil)
        if value
          `new Date(#{value})`
        else
          `new Date()`
        end
      end

      # ===== RegExp Methods =====

      # Create a JavaScript RegExp object
      # @param pattern [String] The regex pattern
      # @param flags [String] Optional flags (e.g., 'gi')
      # @return [Native] JavaScript RegExp object
      def js_regexp(pattern, flags = '')
        `new RegExp(#{pattern}, #{flags})`
      end

      # Test if a string matches a regex pattern
      # @param pattern [String] The regex pattern
      # @param value [String] The string to test
      # @param flags [String] Optional flags
      # @return [Boolean] true if matches
      def js_regexp_test(pattern, value, flags = '')
        `new RegExp(#{pattern}, #{flags}).test(#{value})`
      end

      # ===== Timer Methods =====

      # Set a timeout
      # @param delay [Integer] Delay in milliseconds
      # @yield Block to execute after delay
      # @return [Integer] Timer ID
      def set_timeout(delay, &block)
        `setTimeout(function() { #{block.call} }, #{delay})`
      end

      # Set an interval
      # @param delay [Integer] Interval in milliseconds
      # @yield Block to execute at each interval
      # @return [Integer] Timer ID
      def set_interval(delay, &block)
        `setInterval(function() { #{block.call} }, #{delay})`
      end

      # Clear a timeout
      # @param timer_id [Integer] Timer ID to clear
      def clear_timeout(timer_id)
        `clearTimeout(#{timer_id})`
      end

      # Clear an interval
      # @param timer_id [Integer] Timer ID to clear
      def clear_interval(timer_id)
        `clearInterval(#{timer_id})`
      end

      # ===== Body Style Methods =====

      # Set document body style property
      # @param property [String] CSS property name
      # @param value [String] CSS value
      def body_style(property, value)
        `document.body.style[#{property}] = #{value}`
      end

      # Lock body scroll (prevent scrolling)
      def lock_body_scroll
        body_style('overflow', 'hidden')
      end

      # Unlock body scroll (restore scrolling)
      def unlock_body_scroll
        body_style('overflow', '')
      end

      # ===== Array Helper Methods =====

      # Create a new JavaScript array
      # @return [Native] Empty JavaScript array
      def js_array
        `[]`
      end

      # Push item to JavaScript array
      # @param array [Native] JavaScript array
      # @param item [Object] Item to push
      def js_array_push(array, item)
        `#{array}.push(#{item.to_n})`
      end

      # Get JavaScript array length
      # @param array [Native] JavaScript array
      # @return [Integer] Array length
      def js_array_length(array)
        `#{array}.length`
      end

      # Get item from JavaScript array at index
      # @param array [Native] JavaScript array
      # @param index [Integer] Index
      # @return [Object] Item at index
      def js_array_at(array, index)
        `#{array}[#{index}]`
      end

      # ===== LocalStorage Methods =====

      # Get item from localStorage
      # @param key [String] Storage key
      # @return [String, nil] Stored value or nil
      def storage_get(key)
        `localStorage.getItem(#{key})`
      end

      # Set item in localStorage
      # @param key [String] Storage key
      # @param value [String] Value to store
      def storage_set(key, value)
        `localStorage.setItem(#{key}, #{value})`
      end

      # Remove item from localStorage
      # @param key [String] Storage key
      def storage_remove(key)
        `localStorage.removeItem(#{key})`
      end

      # Get JSON-parsed value from localStorage
      # @param key [String] Storage key
      # @param default [Object] Default value if key doesn't exist
      # @return [Object] Parsed value or default
      def storage_get_json(key, default = nil)
        stored = storage_get(key)
        return default if `#{stored} === null`
        `JSON.parse(#{stored})`
      end

      # Set JSON-stringified value in localStorage
      # @param key [String] Storage key
      # @param value [Object] Value to store (will be JSON-stringified)
      def storage_set_json(key, value)
        `localStorage.setItem(#{key}, JSON.stringify(#{value.to_n}))`
      end

      # ===== Event Methods =====

      # Dispatch a custom event on window
      # @param name [String] Event name
      # @param detail [Hash] Event detail data
      def dispatch_window_event(name, detail = {})
        `
          const event = new CustomEvent(#{name}, { detail: #{detail.to_n} });
          window.dispatchEvent(event);
        `
      end

      # Dispatch a custom event on the controller element
      # @param name [String] Event name
      # @param detail [Hash] Event detail data
      def dispatch_event(name, detail = {})
        `
          const event = new CustomEvent(#{name}, { detail: #{detail.to_n} });
          this.element.dispatchEvent(event);
        `
      end

      # Add window event listener
      # @param name [String] Event name
      # @yield Block to execute when event fires
      def on_window_event(name, &block)
        `window.addEventListener(#{name}, function(e) { #{block.call(`e`)} })`
      end

      # Get the current event's target element
      # @return [Native] Event target element
      def event_target
        `event.currentTarget`
      end

      # Get data attribute from current event target
      # @param attr [String] Data attribute name (without 'data-' prefix)
      # @return [String, nil] Attribute value
      def event_data(attr)
        `event.currentTarget.getAttribute('data-' + #{attr})`
      end

      # Get integer data attribute from current event target
      # @param attr [String] Data attribute name (without 'data-' prefix)
      # @return [Integer, nil] Parsed integer value
      def event_data_int(attr)
        parse_int(event_data(attr))
      end

      # Prevent default event behavior
      def prevent_default
        `event.preventDefault()`
      end

      # Get event key (for keyboard events)
      # @return [String] Key name
      def event_key
        `event.key`
      end

      # ===== Element Methods =====

      # Add class to element
      # @param element [Native] DOM element
      # @param class_name [String] CSS class to add
      def add_class(element, class_name)
        `#{element}.classList.add(#{class_name})`
      end

      # Remove class from element
      # @param element [Native] DOM element
      # @param class_name [String] CSS class to remove
      def remove_class(element, class_name)
        `#{element}.classList.remove(#{class_name})`
      end

      # Toggle class on element
      # @param element [Native] DOM element
      # @param class_name [String] CSS class to toggle
      def toggle_class(element, class_name)
        `#{element}.classList.toggle(#{class_name})`
      end

      # Check if element has class
      # @param element [Native] DOM element
      # @param class_name [String] CSS class to check
      # @return [Boolean]
      def has_class?(element, class_name)
        `#{element}.classList.contains(#{class_name})`
      end

      # Set element attribute
      # @param element [Native] DOM element
      # @param attr [String] Attribute name
      # @param value [String] Attribute value
      def set_attr(element, attr, value)
        `#{element}.setAttribute(#{attr}, #{value})`
      end

      # Get element attribute
      # @param element [Native] DOM element
      # @param attr [String] Attribute name
      # @return [String, nil] Attribute value
      def get_attr(element, attr)
        `#{element}.getAttribute(#{attr})`
      end

      # Remove element attribute
      # @param element [Native] DOM element
      # @param attr [String] Attribute name
      def remove_attr(element, attr)
        `#{element}.removeAttribute(#{attr})`
      end

      # Set element style
      # @param element [Native] DOM element
      # @param property [String] CSS property
      # @param value [String] CSS value
      def set_style(element, property, value)
        `#{element}.style[#{property}] = #{value}`
      end

      # Set element innerHTML
      # @param element [Native] DOM element
      # @param html [String] HTML content
      def set_html(element, html)
        `#{element}.innerHTML = #{html}`
      end

      # Set element textContent
      # @param element [Native] DOM element
      # @param text [String] Text content
      def set_text(element, text)
        `#{element}.textContent = #{text}`
      end

      # Get element value (for inputs)
      # @param element [Native] DOM element
      # @return [String] Element value
      def get_value(element)
        `#{element}.value`
      end

      # Set element value (for inputs)
      # @param element [Native] DOM element
      # @param value [String] Value to set
      def set_value(element, value)
        `#{element}.value = #{value}`
      end

      # Focus element
      # @param element [Native] DOM element
      def focus(element)
        `#{element}.focus()`
      end

      # Check if element has attribute
      # @param element [Native] DOM element
      # @param attr [String] Attribute name
      # @return [Boolean]
      def has_attr?(element, attr)
        `#{element}.hasAttribute(#{attr})`
      end

      # ===== DOM Creation Methods =====

      # Create a new DOM element
      # @param tag [String] HTML tag name
      # @return [Native] Created element
      def create_element(tag)
        `document.createElement(#{tag})`
      end

      # Append child to element
      # @param parent [Native] Parent element
      # @param child [Native] Child element to append
      def append_child(parent, child)
        `#{parent}.appendChild(#{child})`
      end

      # Remove element from DOM
      # @param element [Native] Element to remove
      def remove_element(element)
        `#{element}.remove()`
      end

      # Get next element sibling
      # @param element [Native] DOM element
      # @return [Native, nil] Next sibling element
      def next_sibling(element)
        `#{element}.nextElementSibling`
      end

      # Get previous element sibling
      # @param element [Native] DOM element
      # @return [Native, nil] Previous sibling element
      def prev_sibling(element)
        `#{element}.previousElementSibling`
      end

      # Get parent element
      # @param element [Native] DOM element
      # @return [Native, nil] Parent element
      def parent(element)
        `#{element}.parentElement`
      end

      # ===== DOM Query Methods =====

      # Query selector on document
      # @param selector [String] CSS selector
      # @return [Native, nil] Element or nil
      def query(selector)
        `document.querySelector(#{selector})`
      end

      # Query selector all on document
      # @param selector [String] CSS selector
      # @return [Array] Array of elements
      def query_all(selector)
        `Array.from(document.querySelectorAll(#{selector}))`
      end

      # Query selector on controller element
      # @param selector [String] CSS selector
      # @return [Native, nil] Element or nil
      def query_element(selector)
        `this.element.querySelector(#{selector})`
      end

      # Query selector all on controller element
      # @param selector [String] CSS selector
      # @return [Array] Array of elements
      def query_all_element(selector)
        `Array.from(this.element.querySelectorAll(#{selector}))`
      end

      # ===== Document Methods =====

      # Get document root element (html)
      # @return [Native] HTML element
      def doc_root
        `document.documentElement`
      end

      # Set attribute on document root
      # @param attr [String] Attribute name
      # @param value [String] Attribute value
      def set_root_attr(attr, value)
        `document.documentElement.setAttribute(#{attr}, #{value})`
      end

      # Get attribute from document root
      # @param attr [String] Attribute name
      # @return [String, nil] Attribute value
      def get_root_attr(attr)
        `document.documentElement.getAttribute(#{attr})`
      end

      # ===== Template Methods =====

      # Clone a template target's content
      # @param name [Symbol, String] Template target name
      # @return [Native] Cloned content
      def clone_template(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].content.cloneNode(true)`
      end

      # Get first element child from cloned template
      # @param clone [Native] Cloned template content
      # @return [Native, nil] First element child
      def template_first_child(clone)
        `#{clone}.firstElementChild`
      end

      # ===== Stimulus Controller Element Methods =====

      # Add class to controller element
      # @param class_name [String] CSS class to add
      def element_add_class(class_name)
        `this.element.classList.add(#{class_name})`
      end

      # Remove class from controller element
      # @param class_name [String] CSS class to remove
      def element_remove_class(class_name)
        `this.element.classList.remove(#{class_name})`
      end

      # Toggle class on controller element
      # @param class_name [String] CSS class to toggle
      def element_toggle_class(class_name)
        `this.element.classList.toggle(#{class_name})`
      end

      # ===== Utility Methods =====

      # Generate a unique ID based on timestamp
      # @return [Integer] Unique ID
      def generate_id
        js_timestamp
      end

      # Focus a target element
      # @param name [Symbol, String] Target name
      def target_focus(name)
        return unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].focus()`
      end

      # Blur (unfocus) a target element
      # @param name [Symbol, String] Target name
      def target_blur(name)
        return unless has_target?(name)
        method_name = "#{camelize(name, false)}Target"
        `this[#{method_name}].blur()`
      end

      # ===== Type Conversion Methods =====

      # Parse string to integer (wrapper for JavaScript parseInt)
      # @param value [String, Number] Value to parse
      # @param radix [Integer] Radix (default: 10)
      # @return [Integer, NaN] Parsed integer
      def parse_int(value, radix = 10)
        `parseInt(#{value}, #{radix})`
      end

      # Parse string to float (wrapper for JavaScript parseFloat)
      # @param value [String, Number] Value to parse
      # @return [Float, NaN] Parsed float
      def parse_float(value)
        `parseFloat(#{value})`
      end

      # Check if value is NaN
      # @param value [Number] Value to check
      # @return [Boolean] true if NaN
      def is_nan?(value)
        `Number.isNaN(#{value})`
      end

      # Parse integer with default value (returns default if NaN)
      # @param value [String, Number] Value to parse
      # @param default_value [Integer] Default value if parsing fails
      # @return [Integer] Parsed integer or default
      def parse_int_or(value, default_value = 0)
        result = parse_int(value)
        is_nan?(result) ? default_value : result
      end

      # Parse float with default value (returns default if NaN)
      # @param value [String, Number] Value to parse
      # @param default_value [Float] Default value if parsing fails
      # @return [Float] Parsed float or default
      def parse_float_or(value, default_value = 0.0)
        result = parse_float(value)
        is_nan?(result) ? default_value : result
      end

      private

      # Convert snake_case to camelCase
      # @param name [Symbol, String] The name to convert
      # @param capitalize_first [Boolean] Whether to capitalize first letter
      # @return [String] camelCase string
      def camelize(name, capitalize_first = true)
        str = name.to_s
        parts = str.split('_')
        if capitalize_first
          parts.map(&:capitalize).join
        else
          ([parts.first] + parts[1..-1].map(&:capitalize)).join
        end
      end
    end
  end
end

# Alias for backward compatibility
StimulusHelpers = OpalVite::Concerns::StimulusHelpers

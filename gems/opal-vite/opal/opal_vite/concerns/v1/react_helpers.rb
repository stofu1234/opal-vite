# backtick_javascript: true

module OpalVite
  module Concerns
    module V1
      # ReactHelpers - DSL helpers for React applications with Opal
      # Reduces backtick JavaScript usage in React components
      module ReactHelpers
        # ===================
        # React Access
        # ===================

        # Get React from window
        def react
          Native(`window.React`)
        end

        # Get ReactDOM from window
        def react_dom
          Native(`window.ReactDOM`)
        end

        # ===================
        # Window/Global Access
        # ===================

        # Get a property from window
        def window_get(key)
          `window[#{key}]`
        end

        # Set a property on window
        def window_set(key, value)
          `window[#{key}] = #{value}`
        end

        # Delete a property from window
        def window_delete(key)
          `delete window[#{key}]`
        end

        # ===================
        # Console
        # ===================

        # Console log
        def console_log(*args)
          `console.log(...#{args})`
        end

        # Console warn
        def console_warn(*args)
          `console.warn(...#{args})`
        end

        # Console error
        def console_error(*args)
          `console.error(...#{args})`
        end

        # ===================
        # Alerts/Dialogs
        # ===================

        # Show alert dialog
        def alert_message(message)
          `alert(#{message})`
        end

        # Show confirm dialog
        def confirm_message(message)
          `confirm(#{message})`
        end

        # Show prompt dialog
        def prompt_message(message, default_value = '')
          `prompt(#{message}, #{default_value})`
        end

        # ===================
        # DOM Events
        # ===================

        # Execute block when DOM is ready
        def on_dom_ready(&block)
          `document.addEventListener('DOMContentLoaded', #{block})`
        end

        # Add event listener to window
        def on_window_event(event_name, &block)
          `window.addEventListener(#{event_name}, #{block})`
        end

        # Remove event listener from window
        def off_window_event(event_name, handler)
          `window.removeEventListener(#{event_name}, #{handler})`
        end

        # ===================
        # DOM Query
        # ===================

        # Query single element
        def query(selector)
          `document.querySelector(#{selector})`
        end

        # Query all elements
        def query_all(selector)
          `Array.from(document.querySelectorAll(#{selector}))`
        end

        # Get element by ID
        def get_element_by_id(id)
          `document.getElementById(#{id})`
        end

        # ===================
        # DOM Manipulation
        # ===================

        # Create element
        def create_element(tag)
          `document.createElement(#{tag})`
        end

        # Set innerHTML
        def set_html(element, html)
          `#{element}.innerHTML = #{html}`
        end

        # Set textContent
        def set_text(element, text)
          `#{element}.textContent = #{text}`
        end

        # Add class to element
        def add_class(element, *classes)
          `#{element}.classList.add(...#{classes})`
        end

        # Remove class from element
        def remove_class(element, *classes)
          `#{element}.classList.remove(...#{classes})`
        end

        # ===================
        # React Element Creation Helpers
        # ===================

        # Create React element (shorthand)
        def el(type, props = nil, *children)
          react.createElement(type, props, *children)
        end

        # Create div element
        def div(props = nil, *children, &block)
          if block_given?
            react.createElement('div', props, block.call)
          else
            react.createElement('div', props, *children)
          end
        end

        # Create span element
        def span(props = nil, *children, &block)
          if block_given?
            react.createElement('span', props, block.call)
          else
            react.createElement('span', props, *children)
          end
        end

        # Create button element
        def button(props = nil, *children, &block)
          if block_given?
            react.createElement('button', props, block.call)
          else
            react.createElement('button', props, *children)
          end
        end

        # Create p element
        def paragraph(props = nil, *children, &block)
          if block_given?
            react.createElement('p', props, block.call)
          else
            react.createElement('p', props, *children)
          end
        end

        # Create heading elements
        def h1(props = nil, *children)
          react.createElement('h1', props, *children)
        end

        def h2(props = nil, *children)
          react.createElement('h2', props, *children)
        end

        def h3(props = nil, *children)
          react.createElement('h3', props, *children)
        end

        # ===================
        # Timing
        # ===================

        # Set timeout
        def set_timeout(delay_ms, &block)
          `setTimeout(#{block}, #{delay_ms})`
        end

        # Set interval
        def set_interval(interval_ms, &block)
          `setInterval(#{block}, #{interval_ms})`
        end

        # Clear timeout
        def clear_timeout(timeout_id)
          `clearTimeout(#{timeout_id})`
        end

        # Clear interval
        def clear_interval(interval_id)
          `clearInterval(#{interval_id})`
        end

        # ===================
        # LocalStorage
        # ===================

        # Get from localStorage
        def storage_get(key)
          `localStorage.getItem(#{key})`
        end

        # Set to localStorage
        def storage_set(key, value)
          `localStorage.setItem(#{key}, #{value})`
        end

        # Remove from localStorage
        def storage_remove(key)
          `localStorage.removeItem(#{key})`
        end

        # ===================
        # Fetch API
        # ===================

        # Fetch with promise (returns Native promise)
        def fetch_url(url, options = nil)
          if options
            Native(`fetch(#{url}, #{options.to_n})`)
          else
            Native(`fetch(#{url})`)
          end
        end

        # ===================
        # JSON
        # ===================

        # Parse JSON string
        def parse_json(json_string)
          `JSON.parse(#{json_string})`
        end

        # Stringify to JSON
        def to_json(object)
          `JSON.stringify(#{object})`
        end

        # ===================
        # Type Conversion
        # ===================

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
      end
    end
  end
end

# Alias for backward compatibility
ReactHelpers = OpalVite::Concerns::V1::ReactHelpers

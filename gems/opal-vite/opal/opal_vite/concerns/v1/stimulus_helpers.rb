# backtick_javascript: true

module OpalVite
  module Concerns
    module V1
      # StimulusHelpers - DSL macros for reducing JavaScript backticks in Stimulus controllers
      #
      # This module provides Ruby-friendly methods for common Stimulus patterns,
      # reducing the need for raw JavaScript backticks.
      #
      # Usage:
      #   class MyController < StimulusController
      #     include OpalVite::Concerns::V1::StimulusHelpers
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
        native_detail = detail.is_a?(Hash) ? detail.to_n : detail
        `
          const event = new CustomEvent(#{name}, { detail: #{native_detail} });
          window.dispatchEvent(event);
        `
      end

      # Dispatch a custom event on the controller element
      # @param name [String] Event name
      # @param detail [Hash] Event detail data
      def dispatch_event(name, detail = {})
        native_detail = detail.is_a?(Hash) ? detail.to_n : detail
        `
          const event = new CustomEvent(#{name}, { detail: #{native_detail} });
          this.element.dispatchEvent(event);
        `
      end

      # Add window event listener
      # @param name [String] Event name
      # @yield Block to execute when event fires
      def on_window_event(name, &block)
        `window.addEventListener(#{name}, #{block})`
      end

      # Remove window event listener
      # @param name [String] Event name
      # @param handler [Native] Handler function to remove
      def off_window_event(name, handler)
        `window.removeEventListener(#{name}, #{handler})`
      end

      # Add document event listener
      # @param name [String] Event name
      # @yield Block to execute when event fires
      def on_document_event(name, &block)
        `document.addEventListener(#{name}, #{block})`
      end

      # Add event listener when DOM is ready
      # @yield Block to execute when DOM is ready
      def on_dom_ready(&block)
        `document.addEventListener('DOMContentLoaded', #{block})`
      end

      # Add event listener to any element
      # @param element [Native] DOM element
      # @param name [String] Event name
      # @yield Block to execute when event fires
      def on_element_event(element, name, &block)
        `#{element}.addEventListener(#{name}, #{block})`
      end

      # Remove event listener from element
      # @param element [Native] DOM element
      # @param name [String] Event name
      # @param handler [Native] Handler function to remove
      def off_element_event(element, name, handler)
        `#{element}.removeEventListener(#{name}, #{handler})`
      end

      # Add event listener to controller's element (this.element)
      # @param name [String] Event name
      # @yield Block to execute when event fires
      def on_controller_event(name, &block)
        `
          const handler = #{block};
          this.element.addEventListener(#{name}, function(e) {
            handler(e);
          });
        `
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

      # ===== JavaScript Property Access Methods =====

      # Get a JavaScript property from the controller (this[name])
      # @param name [Symbol, String] Property name
      # @return [Native] Property value
      def js_prop(name)
        `this[#{name.to_s}]`
      end

      # Set a JavaScript property on the controller (this[name] = value)
      # @param name [Symbol, String] Property name
      # @param value [Object] Value to set
      def js_set_prop(name, value)
        `this[#{name.to_s}] = #{value}`
      end

      # Check if controller has a JavaScript property
      # @param name [Symbol, String] Property name
      # @return [Boolean] true if property exists and is truthy
      def js_has_prop?(name)
        `!!this[#{name.to_s}]`
      end

      # Call a JavaScript method on the controller (this[name](...args))
      # @param name [Symbol, String] Method name
      # @param args [Array] Arguments to pass
      # @return [Native] Method return value
      def js_call(name, *args)
        if args.empty?
          `this[#{name.to_s}]()`
        else
          native_args = args.map { |a| a.respond_to?(:to_n) ? a.to_n : a }
          `this[#{name.to_s}].apply(this, #{native_args})`
        end
      end

      # Call a method on a JavaScript object
      # @param obj [Native] JavaScript object
      # @param method [Symbol, String] Method name
      # @param args [Array] Arguments to pass
      # @return [Native] Method return value
      def js_call_on(obj, method, *args)
        if args.empty?
          `#{obj}[#{method.to_s}]()`
        else
          native_args = args.map { |a| a.respond_to?(:to_n) ? a.to_n : a }
          `#{obj}[#{method.to_s}].apply(#{obj}, #{native_args})`
        end
      end

      # Get a property from a JavaScript object
      # @param obj [Native] JavaScript object
      # @param prop [Symbol, String] Property name
      # @return [Native] Property value
      def js_get(obj, prop)
        `#{obj}[#{prop.to_s}]`
      end

      # Set a property on a JavaScript object
      # @param obj [Native] JavaScript object
      # @param prop [Symbol, String] Property name
      # @param value [Object] Value to set
      def js_set(obj, prop, value)
        `#{obj}[#{prop.to_s}] = #{value}`
      end

      # ===== JSON Methods =====

      # Parse JSON string to JavaScript object
      # @param json_string [String] JSON string
      # @return [Native] Parsed JavaScript object
      def json_parse(json_string)
        `JSON.parse(#{json_string})`
      end

      # Stringify JavaScript object to JSON
      # @param obj [Object] Object to stringify
      # @return [String] JSON string
      def json_stringify(obj)
        native_obj = obj.respond_to?(:to_n) ? obj.to_n : obj
        `JSON.stringify(#{native_obj})`
      end

      # ===== Console Methods =====

      # Log to console
      # @param args [Array] Arguments to log
      def console_log(*args)
        `console.log.apply(console, #{args})`
      end

      # Log warning to console
      # @param args [Array] Arguments to log
      def console_warn(*args)
        `console.warn.apply(console, #{args})`
      end

      # Log error to console
      # @param args [Array] Arguments to log
      def console_error(*args)
        `console.error.apply(console, #{args})`
      end

      # ===== String Methods =====

      # Get character at index from string
      # @param str [String] JavaScript string
      # @param index [Integer] Character index
      # @return [String] Character at index
      def js_string_char_at(str, index)
        `#{str}.charAt(#{index})`
      end

      # Get substring
      # @param str [String] JavaScript string
      # @param start [Integer] Start index
      # @param end_idx [Integer, nil] End index (optional)
      # @return [String] Substring
      def js_substring(str, start, end_idx = nil)
        if end_idx
          `#{str}.substring(#{start}, #{end_idx})`
        else
          `#{str}.substring(#{start})`
        end
      end

      # Split string
      # @param str [String] JavaScript string
      # @param separator [String] Separator
      # @return [Native] Array of substrings
      def js_split(str, separator)
        `#{str}.split(#{separator})`
      end

      # Trim whitespace from string
      # @param str [String] JavaScript string
      # @return [String] Trimmed string
      def js_trim(str)
        `#{str}.trim()`
      end

      # Check if string includes substring
      # @param str [String] JavaScript string
      # @param search [String] Substring to search for
      # @return [Boolean] true if includes
      def js_includes?(str, search)
        `#{str}.includes(#{search})`
      end

      # ===== Comparison Methods =====

      # Check strict equality (===) between two JavaScript values
      # @param a [Native] First value
      # @param b [Native] Second value
      # @return [Boolean] true if strictly equal
      def js_equals?(a, b)
        `#{a} === #{b}`
      end

      # Check loose equality (==) between two JavaScript values
      # @param a [Native] First value
      # @param b [Native] Second value
      # @return [Boolean] true if loosely equal
      def js_loose_equals?(a, b)
        `#{a} == #{b}`
      end

      # ===== Math Methods =====

      # Generate random number between 0 and 1
      # @return [Float] Random number
      def js_random
        `Math.random()`
      end

      # Get minimum of two numbers
      # @param a [Number] First number
      # @param b [Number] Second number
      # @return [Number] Minimum value
      def js_min(a, b)
        `Math.min(#{a}, #{b})`
      end

      # Get maximum of two numbers
      # @param a [Number] First number
      # @param b [Number] Second number
      # @return [Number] Maximum value
      def js_max(a, b)
        `Math.max(#{a}, #{b})`
      end

      # Get absolute value
      # @param num [Number] Number
      # @return [Number] Absolute value
      def js_abs(num)
        `Math.abs(#{num})`
      end

      # Round number
      # @param num [Number] Number
      # @return [Integer] Rounded number
      def js_round(num)
        `Math.round(#{num})`
      end

      # Ceiling of number
      # @param num [Number] Number
      # @return [Integer] Ceiling value
      def js_ceil(num)
        `Math.ceil(#{num})`
      end

      # Format number with fixed decimal places
      # @param num [Number] Number to format
      # @param digits [Integer] Number of decimal places
      # @return [String] Formatted number string
      def js_to_fixed(num, digits)
        `#{num}.toFixed(#{digits})`
      end

      # Generate random integer between 0 and max (exclusive)
      # @param max [Integer] Maximum value (exclusive)
      # @return [Integer] Random integer
      def random_int(max)
        `Math.floor(Math.random() * #{max})`
      end

      # Floor a number
      # @param num [Number] Number to floor
      # @return [Integer] Floored number
      def js_floor(num)
        `Math.floor(#{num})`
      end

      # ===== Global Object Access =====

      # Check if a global JavaScript object/class exists
      # @param name [String] Global name (e.g., 'Chart', 'React')
      # @return [Boolean] true if exists
      def js_global_exists?(name)
        `typeof window[#{name}] !== 'undefined'`
      end

      # Get a global JavaScript object/class
      # @param name [String] Global name
      # @return [Native] Global object
      def js_global(name)
        `window[#{name}]`
      end

      # Create new instance of a JavaScript class
      # @param klass [Native] JavaScript class/constructor
      # @param args [Array] Constructor arguments
      # @return [Native] New instance
      def js_new(klass, *args)
        if args.empty?
          `new klass()`
        else
          # Convert Ruby objects to native, pass JS objects as-is
          native_args = args.map { |a| `#{a} != null && typeof #{a}.$to_n === 'function' ? #{a}.$to_n() : #{a}` }
          # Use Reflect.construct for dynamic argument passing
          `Reflect.construct(#{klass}, #{native_args})`
        end
      end

      # Define a JavaScript function on the controller (this[name] = function)
      # @param name [Symbol, String] Function name
      # @yield Block that becomes the function body
      def js_define_method(name, &block)
        `this[#{name.to_s}] = #{block}`
      end

      # Define a JavaScript function on an object (obj[name] = function)
      # @param obj [Native] JavaScript object
      # @param name [Symbol, String] Function name
      # @yield Block that becomes the function body
      def js_define_method_on(obj, name, &block)
        `#{obj}[#{name.to_s}] = #{block}`
      end

      # ===== Array Methods =====

      # Get array length
      # @param arr [Native] JavaScript array
      # @return [Integer] Array length
      def js_length(arr)
        `#{arr}.length`
      end

      # Map over array with block
      # @param arr [Native] JavaScript array
      # @yield [item] Block to execute for each item
      # @return [Native] New array with mapped values
      def js_map(arr, &block)
        `#{arr}.map(#{block})`
      end

      # Filter array with block
      # @param arr [Native] JavaScript array
      # @yield [item] Block to execute for each item
      # @return [Native] Filtered array
      def js_filter(arr, &block)
        `#{arr}.filter(#{block})`
      end

      # Reduce array with block
      # @param arr [Native] JavaScript array
      # @param initial [Object] Initial value
      # @yield [acc, item] Block to execute for each item
      # @return [Object] Reduced value
      def js_reduce(arr, initial, &block)
        `#{arr}.reduce(#{block}, #{initial})`
      end

      # ForEach over array with block
      # @param arr [Native] JavaScript array
      # @yield [item, index] Block to execute for each item
      def js_each(arr, &block)
        `#{arr}.forEach(#{block})`
      end

      # Slice array
      # @param arr [Native] JavaScript array
      # @param start [Integer] Start index
      # @param end_idx [Integer, nil] End index (optional)
      # @return [Native] Sliced array
      def js_slice(arr, start, end_idx = nil)
        if end_idx
          `#{arr}.slice(#{start}, #{end_idx})`
        else
          `#{arr}.slice(#{start})`
        end
      end

      # ===== Object Methods =====

      # Create empty JavaScript object
      # @return [Native] Empty JavaScript object
      def js_object
        `{}`
      end

      # Get object keys
      # @param obj [Native] JavaScript object
      # @return [Native] Array of keys
      def js_keys(obj)
        `Object.keys(#{obj})`
      end

      # Get object values
      # @param obj [Native] JavaScript object
      # @return [Native] Array of values
      def js_values(obj)
        `Object.values(#{obj})`
      end

      # Get object entries
      # @param obj [Native] JavaScript object
      # @return [Native] Array of [key, value] pairs
      def js_entries(obj)
        `Object.entries(#{obj})`
      end

      # Create Set from array and get size
      # @param arr [Native] JavaScript array
      # @return [Integer] Number of unique elements
      def js_unique_count(arr)
        `new Set(#{arr}).size`
      end

      # ===== Fetch API =====

      # Simple fetch that returns Promise-wrapped response
      # @param url [String] URL to fetch
      # @return [Native] Promise
      def js_fetch(url)
        `fetch(#{url})`
      end

      # Fetch JSON from URL with callback
      # @param url [String] URL to fetch
      # @yield [data] Block to handle response data
      def fetch_json(url, &success_block)
        `
          fetch(#{url})
            .then(response => response.json())
            .then(data => #{success_block}.$call(data))
            .catch(error => console.error('Fetch error:', error))
        `
      end

      # Fetch JSON from URL returning a Promise (for chaining)
      # @param url [String] URL to fetch
      # @return [Native] Promise that resolves to JSON data
      def fetch_json_promise(url)
        `fetch(#{url}).then(response => response.json())`
      end

      # Fetch JSON with response validation
      # @param url [String] URL to fetch
      # @return [Native] Promise that resolves to JSON data or rejects on error
      def fetch_json_safe(url)
        `fetch(#{url}).then(function(response) { if (!response.ok) { throw new Error('Network response was not ok: ' + response.status); } return response.json(); })`
      end

      # Fetch multiple URLs in parallel and get JSON results
      # @param urls [Array<String>] URLs to fetch
      # @return [Native] Promise that resolves to array of JSON results
      def fetch_all_json(urls)
        promises = urls.map { |url| fetch_json_promise(url) }
        `Promise.all(#{promises})`
      end

      # Fetch JSON with success and error callbacks
      # @param url [String] URL to fetch
      # @param on_success [Proc] Success callback receiving data
      # @param on_error [Proc] Error callback receiving error
      def fetch_json_with_handlers(url, on_success:, on_error: nil)
        promise = fetch_json_safe(url)
        promise = js_then(promise) { |data| on_success.call(data) }
        if on_error
          js_catch(promise) { |error| on_error.call(error) }
        else
          js_catch(promise) { |error| console_error('Fetch error:', error) }
        end
      end

      # ===== Promise Methods =====

      # Create Promise.all from array of promises
      # @param promises [Array<Native>] Array of promises
      # @return [Native] Promise that resolves when all complete
      def promise_all(promises)
        `Promise.all(#{promises})`
      end

      # Create Promise.race from array of promises
      # @param promises [Array<Native>] Array of promises
      # @return [Native] Promise that resolves when first completes
      def promise_race(promises)
        `Promise.race(#{promises})`
      end

      # Create a resolved Promise with value
      # @param value [Object] Value to resolve with
      # @return [Native] Resolved Promise
      def promise_resolve(value)
        native_value = value.respond_to?(:to_n) ? value.to_n : value
        `Promise.resolve(#{native_value})`
      end

      # Create a rejected Promise with error
      # @param error [Object] Error to reject with
      # @return [Native] Rejected Promise
      def promise_reject(error)
        `Promise.reject(#{error})`
      end

      # Add then handler to promise
      # @param promise [Native] JavaScript Promise
      # @yield [value] Block to handle resolved value
      # @return [Native] New Promise
      def js_then(promise, &block)
        `#{promise}.then(#{block})`
      end

      # Add catch handler to promise
      # @param promise [Native] JavaScript Promise
      # @yield [error] Block to handle rejection
      # @return [Native] New Promise
      def js_catch(promise, &block)
        `#{promise}.catch(#{block})`
      end

      # Add finally handler to promise
      # @param promise [Native] JavaScript Promise
      # @yield Block to execute regardless of outcome
      # @return [Native] New Promise
      def js_finally(promise, &block)
        `#{promise}.finally(#{block})`
      end

      private

      # Convert snake_case to camelCase, preserving existing camelCase
      # @param name [Symbol, String] The name to convert
      # @param capitalize_first [Boolean] Whether to capitalize first letter
      # @return [String] camelCase string
      def camelize(name, capitalize_first = true)
        str = name.to_s

        # If no underscores, assume already camelCase - just adjust first letter
        unless str.include?('_')
          if capitalize_first
            return str[0].upcase + str[1..-1].to_s
          else
            return str[0].downcase + str[1..-1].to_s
          end
        end

        # Convert snake_case to camelCase
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
end

# Alias for backward compatibility
StimulusHelpers = OpalVite::Concerns::V1::StimulusHelpers

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

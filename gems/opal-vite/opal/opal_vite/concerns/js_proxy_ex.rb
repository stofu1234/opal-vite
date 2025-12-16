# backtick_javascript: true

module OpalVite
  module Concerns
    # JS::ProxyEx - Extended JS proxy utilities for Ruby-like JavaScript interop
    #
    # This module provides Ruby-friendly wrappers around JavaScript objects and APIs
    # that opal_stimulus's JS::Proxy doesn't fully cover yet.
    #
    # Usage:
    #   include OpalVite::Concerns::JsProxyEx
    #
    #   # Global objects
    #   local_storage.get_item('key')
    #   json.parse(data)
    #
    #   # Object creation
    #   new_event('click', bubbles: true)
    #   new_url('https://example.com')
    #   new_regexp('[a-z]+')
    #
    #   # Event listeners with proper block handling
    #   window.add_event_listener('click') { |event| ... }
    #
    module JsProxyEx
      # ============================================
      # Global JavaScript Objects
      # ============================================

      def local_storage
        @local_storage ||= JsObject.new(`localStorage`)
      end

      def session_storage
        @session_storage ||= JsObject.new(`sessionStorage`)
      end

      def js_json
        @js_json ||= JsonWrapper.new
      end

      def js_date
        DateWrapper
      end

      def js_console
        @js_console ||= JsObject.new(`console`)
      end

      # ============================================
      # Object Creation Helpers
      # ============================================

      def new_event(type, options = {})
        JsObject.new(`new Event(#{type}, #{options.to_n})`)
      end

      def new_custom_event(type, detail = {})
        JsObject.new(`new CustomEvent(#{type}, { detail: #{detail.to_n} })`)
      end

      def new_url(url_string)
        JsObject.new(`new URL(#{url_string})`)
      end

      def new_regexp(pattern, flags = '')
        RegExpWrapper.new(pattern, flags)
      end

      def new_date(value = nil)
        if value
          JsObject.new(`new Date(#{value})`)
        else
          JsObject.new(`new Date()`)
        end
      end

      def date_now
        `Date.now()`
      end

      # ============================================
      # Wrap existing JS::Proxy objects
      # ============================================

      # Wrap a JS::Proxy or native object in JsObject for enhanced access
      def wrap_js(obj)
        return nil if obj.nil?
        native = obj.respond_to?(:to_n) ? obj.to_n : obj
        JsObject.new(native)
      end

      # ============================================
      # Array/Object utilities
      # ============================================

      # Convert JS array to Ruby array with JsObject wrapping
      def js_array_to_ruby(js_array)
        result = []
        length = `#{js_array}.length`
        length.times do |i|
          item = `#{js_array}[#{i}]`
          result << JsObject.new(item)
        end
        result
      end

      # Create empty JS array
      def new_js_array
        JsObject.new(`[]`)
      end

      # ============================================
      # JsObject - Wrapper class with method_missing
      # ============================================

      class JsObject
        def initialize(native)
          @native = native
        end

        def to_n
          @native
        end

        # Access properties with [] - returns wrapped JsObject
        def [](key)
          key_str = key.to_s
          # Convert snake_case to camelCase for property access
          camel_key = snake_to_camel(key_str)
          result = `#{@native}[#{camel_key}]`
          wrap_result(result)
        end

        # Set properties with []=
        def []=(key, value)
          key_str = key.to_s
          camel_key = snake_to_camel(key_str)
          native_value = value.respond_to?(:to_n) ? value.to_n : value
          `#{@native}[#{camel_key}] = #{native_value}`
        end

        # Method missing for snake_case -> camelCase conversion
        def method_missing(name, *args, &block)
          name_str = name.to_s

          # Handle setters (e.g., text_content=)
          if name_str.end_with?('=')
            prop_name = name_str[0..-2]
            camel_name = snake_to_camel(prop_name)
            value = args[0]
            native_value = value.respond_to?(:to_n) ? value.to_n : value
            `#{@native}[#{camel_name}] = #{native_value}`
            return value
          end

          # Handle predicates (e.g., has_attribute?)
          if name_str.end_with?('?')
            prop_name = name_str[0..-2]
            camel_name = snake_to_camel(prop_name)
            return !!`#{@native}[#{camel_name}]`
          end

          camel_name = snake_to_camel(name_str)

          # Check if it's a function
          is_function = `typeof #{@native}[#{camel_name}] === 'function'`

          if is_function
            # Handle event listeners specially
            if camel_name == 'addEventListener' && block
              native_callback = ->(event) { block.call(JsObject.new(event)) }
              `#{@native}.addEventListener(#{args[0]}, #{native_callback})`
              return nil
            end

            # Convert args to native
            native_args = args.map { |a| a.respond_to?(:to_n) ? a.to_n : a }

            # If block provided, wrap it
            if block
              native_callback = ->(*cb_args) {
                wrapped_args = cb_args.map { |a| wrap_result(a) }
                block.call(*wrapped_args)
              }
              native_args << native_callback
            end

            result = case native_args.length
            when 0 then `#{@native}[#{camel_name}]()`
            when 1 then `#{@native}[#{camel_name}](#{native_args[0]})`
            when 2 then `#{@native}[#{camel_name}](#{native_args[0]}, #{native_args[1]})`
            when 3 then `#{@native}[#{camel_name}](#{native_args[0]}, #{native_args[1]}, #{native_args[2]})`
            else
              # For more args, use apply
              `#{@native}[#{camel_name}].apply(#{@native}, #{native_args})`
            end

            wrap_result(result)
          else
            # Property access
            result = `#{@native}[#{camel_name}]`
            wrap_result(result)
          end
        end

        def respond_to_missing?(name, include_private = false)
          true
        end

        # Enumerable support - iterate over array-like objects
        def each(&block)
          return enum_for(:each) unless block
          length = `#{@native}.length`
          return self unless length
          length.times do |i|
            item = `#{@native}[#{i}]`
            block.call(wrap_result(item))
          end
          self
        end

        def length
          `#{@native}.length`
        end

        def size
          length
        end

        # Check for null/undefined
        def nil?
          `#{@native} == null`
        end

        def exists?
          !nil?
        end

        # String conversion
        def to_s
          `String(#{@native})`
        end

        def inspect
          "#<JsObject: #{to_s}>"
        end

        private

        def snake_to_camel(str)
          # Handle special cases first
          return str if str == str.upcase # ALL_CAPS stays as is

          parts = str.split('_')
          return str if parts.length == 1

          # First part stays lowercase, rest get capitalized
          parts[0] + parts[1..-1].map(&:capitalize).join
        end

        def wrap_result(result)
          return nil if `#{result} === null || #{result} === undefined`
          return result if `typeof #{result} === 'number'`
          return result if `typeof #{result} === 'string'`
          return result if `typeof #{result} === 'boolean'`
          JsObject.new(result)
        end
      end

      # ============================================
      # JsonWrapper - Ruby-like JSON API
      # ============================================

      class JsonWrapper
        def parse(json_string)
          result = `JSON.parse(#{json_string})`
          JsObject.new(result)
        end

        def stringify(data)
          native_data = data.respond_to?(:to_n) ? data.to_n : data
          `JSON.stringify(#{native_data})`
        end
      end

      # ============================================
      # RegExpWrapper - Ruby-like RegExp API
      # ============================================

      class RegExpWrapper
        def initialize(pattern, flags = '')
          @native = `new RegExp(#{pattern}, #{flags})`
        end

        def to_n
          @native
        end

        def test(string)
          `#{@native}.test(#{string})`
        end

        def match(string)
          result = `#{string}.match(#{@native})`
          return nil if `#{result} === null`
          JsObject.new(result)
        end

        def =~(string)
          test(string)
        end
      end

      # ============================================
      # DateWrapper - Static methods for Date
      # ============================================

      module DateWrapper
        def self.now
          `Date.now()`
        end

        def self.new(value = nil)
          if value
            JsObject.new(`new Date(#{value})`)
          else
            JsObject.new(`new Date()`)
          end
        end

        def self.parse(date_string)
          `Date.parse(#{date_string})`
        end
      end

      # ============================================
      # Stimulus Target Helpers
      # For accessing Stimulus targets with snake_case
      # ============================================

      # Check if target exists: has_target?(:submit_btn)
      def has_target?(target_name)
        camel_name = snake_to_camel(target_name.to_s)
        has_method = "has#{camel_name[0].upcase}#{camel_name[1..-1]}Target"
        `this[#{has_method}]`
      end

      # Get target element: target(:submit_btn)
      def target(target_name)
        camel_name = snake_to_camel(target_name.to_s)
        target_method = "#{camel_name}Target"
        result = `this[#{target_method}]`
        JsObject.new(result)
      end

      # Get all targets: targets(:field)
      def targets(target_name)
        camel_name = snake_to_camel(target_name.to_s)
        targets_method = "#{camel_name}Targets"
        result = `this[#{targets_method}]`
        js_array_to_ruby(result)
      end

      # Update target text content: set_target_text(:status, "Hello")
      def set_target_text(target_name, text)
        camel_name = snake_to_camel(target_name.to_s)
        has_method = "has#{camel_name[0].upcase}#{camel_name[1..-1]}Target"
        target_method = "#{camel_name}Target"
        `
          if (this[#{has_method}]) {
            this[#{target_method}].textContent = #{text};
          }
        `
      end

      # Update target class: set_target_class(:status, "form-status error")
      def set_target_class(target_name, class_name)
        camel_name = snake_to_camel(target_name.to_s)
        has_method = "has#{camel_name[0].upcase}#{camel_name[1..-1]}Target"
        target_method = "#{camel_name}Target"
        `
          if (this[#{has_method}]) {
            this[#{target_method}].className = #{class_name};
          }
        `
      end

      # Set target disabled state: set_target_disabled(:submit_btn, true)
      def set_target_disabled(target_name, disabled)
        camel_name = snake_to_camel(target_name.to_s)
        has_method = "has#{camel_name[0].upcase}#{camel_name[1..-1]}Target"
        target_method = "#{camel_name}Target"
        `
          if (this[#{has_method}]) {
            this[#{target_method}].disabled = #{disabled};
          }
        `
      end

      private

      def snake_to_camel(str)
        return str if str == str.upcase # ALL_CAPS stays as is
        parts = str.to_s.split('_')
        return str if parts.length == 1
        parts[0] + parts[1..-1].map(&:capitalize).join
      end
    end
  end
end

# Alias for backward compatibility
JsProxyEx = OpalVite::Concerns::JsProxyEx

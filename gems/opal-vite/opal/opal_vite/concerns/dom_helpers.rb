# backtick_javascript: true

module OpalVite
  module Concerns
    # DomHelpers concern - provides common DOM manipulation methods
    module DomHelpers
      # Create a custom event and dispatch it on a target
      def dispatch_custom_event(event_name, detail = {}, target = nil)
        target ||= window
        `
          const event = new CustomEvent(#{event_name}, {
            detail: #{detail.to_n}
          });
          #{target.to_n}.dispatchEvent(event);
        `
      end

      # Create a standard event
      def create_event(event_type, options = { bubbles: true })
        `new Event(#{event_type}, #{options.to_n})`
      end

      # Query selector shorthand on element
      def query(selector)
        element.query_selector(selector)
      end

      # Query selector all shorthand on element
      def query_all(selector)
        element.query_selector_all(selector)
      end

      # Add CSS class to element
      def add_class(el, class_name)
        el.class_list.add(class_name)
      end

      # Remove CSS class from element
      def remove_class(el, class_name)
        el.class_list.remove(class_name)
      end

      # Toggle CSS class on element
      def toggle_class(el, class_name)
        el.class_list.toggle(class_name)
      end

      # Check if element has CSS class
      def has_class?(el, class_name)
        el.class_list.contains(class_name)
      end

      # Set timeout helper
      def set_timeout(delay_ms, &block)
        window.set_timeout(block, delay_ms)
      end

      # Check if element exists (not null)
      def element_exists?(el)
        !el.nil? && el.to_n
      end

      # Set style property on element
      def set_style(el, property, value)
        return unless element_exists?(el)
        `#{el.to_n}.style[#{property}] = #{value}`
      end

      # Get style property from element
      def get_style(el, property)
        return nil unless element_exists?(el)
        `#{el.to_n}.style[#{property}]`
      end

      # Show element (set display to block)
      def show_element(el)
        set_style(el, 'display', 'block')
      end

      # Hide element (set display to none)
      def hide_element(el)
        set_style(el, 'display', 'none')
      end
    end
  end
end

# Alias for backward compatibility
DomHelpers = OpalVite::Concerns::DomHelpers

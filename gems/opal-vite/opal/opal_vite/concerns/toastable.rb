# backtick_javascript: true

module OpalVite
  module Concerns
    # Toastable concern - provides toast notification functionality
    module Toastable
      def dispatch_toast(message, type = 'info')
        `
          const event = new CustomEvent('show-toast', {
            detail: { message: #{message}, type: #{type} }
          });
          window.dispatchEvent(event);
        `
      end

      def show_success(message)
        dispatch_toast(message, 'success')
      end

      def show_error(message)
        dispatch_toast(message, 'error')
      end

      def show_warning(message)
        dispatch_toast(message, 'warning')
      end

      def show_info(message)
        dispatch_toast(message, 'info')
      end
    end
  end
end

# Alias for backward compatibility
Toastable = OpalVite::Concerns::Toastable

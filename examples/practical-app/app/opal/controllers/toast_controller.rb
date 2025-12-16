# backtick_javascript: true

# Toast notification controller
class ToastController < StimulusController
  include JsProxyEx

  self.targets = ["container"]

  ICONS = {
    'info' => 'ℹ️',
    'success' => '✅',
    'error' => '❌',
    'warning' => '⚠️'
  }.freeze

  def connect
    # Listen for show-toast event using backtick for direct JS callback
    `
      const ctrl = this;
      window.addEventListener('show-toast', function(e) {
        ctrl.$show(e.detail.message, e.detail.type || 'info');
      });
    `
  end

  # Show toast notification
  def show(message, type = 'info')
    # Find or create toast container
    container = if has_container_target
                  container_target
                else
                  document.query_selector('.toast-container[data-toast-target="container"]')
                end

    unless container.to_n
      puts "No toast container found"
      return
    end

    # Create toast element
    toast = document.create_element('div')
    toast.class_name = "toast toast-#{type}"

    # Add icon based on type
    icon = ICONS[type] || ICONS['info']

    toast.inner_html = "<span class=\"toast-icon\">#{icon}</span>" \
                       "<span class=\"toast-message\">#{message}</span>"

    container.append_child(toast)

    # Animate in
    window.set_timeout(-> { toast.class_list.add('show') }, 10)

    # Auto remove after 3 seconds
    window.set_timeout(-> {
      toast.class_list.remove('show')
      window.set_timeout(-> { toast.remove }, 300)
    }, 3000)
  end

  # Manually show toast (for testing)
  def show_test
    messages = [
      { text: 'Success message!', type: 'success' },
      { text: 'Error message!', type: 'error' },
      { text: 'Warning message!', type: 'warning' },
      { text: 'Info message!', type: 'info' }
    ]

    random = messages.sample
    show(random[:text], random[:type])
  end
end

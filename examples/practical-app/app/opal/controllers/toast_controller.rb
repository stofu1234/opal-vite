# backtick_javascript: true

# Toast notification controller
class ToastController < StimulusController
  include StimulusHelpers

  self.targets = ["container"]

  def connect
    # Listen for show-toast event
    on_window_event('show-toast') do |e|
      detail = `#{e}.detail`
      message = `#{detail}.message`
      type = `#{detail}.type || 'info'`
      show(message, type)
    end
  end

  # Show toast notification
  def show(message = nil, type = 'info')
    # Get arguments if called from JavaScript
    message ||= `arguments[0]`
    type = `arguments[1] || 'info'` if `arguments.length > 1`

    # Find container
    container = has_target?(:container) ? get_target(:container) : nil
    container ||= query('.toast-container[data-toast-target="container"]')

    unless container
      puts "No toast container found"
      return
    end

    # Create toast element
    toast = create_element('div')
    `#{toast}.className = 'toast toast-' + #{type}`

    # Add icon based on type
    icon = case type
           when 'success' then '✅'
           when 'error' then '❌'
           when 'warning' then '⚠️'
           else 'ℹ️'
           end

    set_html(toast, "<span class=\"toast-icon\">#{icon}</span><span class=\"toast-message\">#{message}</span>")
    append_child(container, toast)

    # Animate in
    set_timeout(10) { add_class(toast, 'show') }

    # Auto remove after 3 seconds
    set_timeout(3000) do
      remove_class(toast, 'show')
      set_timeout(300) { remove_element(toast) }
    end
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

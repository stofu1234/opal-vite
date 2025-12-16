# backtick_javascript: true

# Form validation controller with real-time feedback
class FormController < StimulusController
  include StimulusHelpers

  self.targets = ["input", "error"]

  def connect
  end

  # Validate on input
  def validate
    input = event_target
    error_el = next_sibling(input)
    value = `#{get_value(input)}.trim()`

    # Get validation rules from data attributes
    required = has_attr?(input, 'data-required')
    min_length = parse_int_or(get_attr(input, 'data-min-length'), 0)
    max_length = parse_int_or(get_attr(input, 'data-max-length'), 1000)
    pattern = get_attr(input, 'data-pattern')

    error_message = ''

    # Required validation
    if required && `#{value} === ''`
      error_message = 'This field is required'
    # Min length validation
    elsif `#{min_length} > 0 && #{value}.length < #{min_length}`
      error_message = "Must be at least #{min_length} characters"
    # Max length validation
    elsif `#{max_length} > 0 && #{value}.length > #{max_length}`
      error_message = "Must be at most #{max_length} characters"
    # Pattern validation
    elsif pattern && `#{value} !== ''`
      unless js_regexp_test(pattern, value)
        error_message = 'Invalid format'
      end
    end

    # Show/hide error
    if error_message != ''
      add_class(input, 'error')
      if error_el && has_class?(error_el, 'error-message')
        set_text(error_el, error_message)
        set_style(error_el, 'display', 'block')
      end
    else
      remove_class(input, 'error')
      if error_el && has_class?(error_el, 'error-message')
        set_style(error_el, 'display', 'none')
      end
    end
  end

  # Submit with validation
  def submit
    prevent_default

    # Get all inputs
    inputs = query_all_element('[data-form-target="input"]')
    is_valid = true

    # Validate each input
    inputs.each do |input|
      # Trigger validation for each input
      `
        const validateEvent = new Event('input', { bubbles: true });
        #{input}.dispatchEvent(validateEvent);
      `

      # Check if has error class
      is_valid = false if has_class?(input, 'error')
    end

    unless is_valid
      dispatch_window_event('show-toast', {
        message: 'Please fix validation errors',
        type: 'error'
      })
      return
    end

    # Form is valid, show success toast
    dispatch_window_event('show-toast', {
      message: 'Form submitted successfully!',
      type: 'success'
    })

    # Reset form
    `this.element.reset()`

    # Clear all error states
    inputs.each do |input|
      remove_class(input, 'error')
      error_el = next_sibling(input)
      if error_el && has_class?(error_el, 'error-message')
        set_style(error_el, 'display', 'none')
      end
    end
  end
end

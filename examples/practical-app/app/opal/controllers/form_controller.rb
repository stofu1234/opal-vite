# backtick_javascript: true

# Form validation controller with real-time feedback
class FormController < StimulusController
  include JsProxyEx
  include Toastable
  include DomHelpers

  self.targets = ["input", "error"]

  def connect
  end

  # Validate on input - event is passed by Stimulus action
  def validate(event)
    input = event.current_target
    error_el = input.next_element_sibling
    value = input.value.strip

    # Get validation rules from data attributes
    required = input.has_attribute('data-required')
    min_length = (input.get_attribute('data-min-length') || '0').to_i
    max_length = (input.get_attribute('data-max-length') || '1000').to_i
    pattern = input.get_attribute('data-pattern')

    error_message = validate_value(value, required, min_length, max_length, pattern)

    # Show/hide error
    show_field_error(input, error_el, error_message)
  end

  # Submit with validation
  def submit(event)
    event.prevent_default

    inputs = query_all('[data-form-target="input"]')
    is_valid = true

    # Validate all inputs
    inputs.each do |input|
      # Trigger validation event
      input.dispatch_event(create_event('input'))

      # Check if has error class
      is_valid = false if has_class?(input, 'error')
    end

    unless is_valid
      show_error('Please fix validation errors')
      return
    end

    # Form is valid
    show_success('Form submitted successfully!')

    # Reset form
    element.reset

    # Clear all error states
    inputs.each do |input|
      remove_class(input, 'error')
      error_el = input.next_element_sibling
      if element_exists?(error_el) && has_class?(error_el, 'error-message')
        error_el.style.display = 'none'
      end
    end
  end

  private

  def validate_value(value, required, min_length, max_length, pattern)
    if required && value.empty?
      'This field is required'
    elsif min_length > 0 && value.length < min_length
      "Must be at least #{min_length} characters"
    elsif max_length > 0 && value.length > max_length
      "Must be at most #{max_length} characters"
    elsif pattern && !value.empty?
      regex = `new RegExp(#{pattern})`
      unless `#{regex}.test(#{value})`
        'Invalid format'
      end
    end
  end

  def show_field_error(input, error_el, error_message)
    if error_message
      add_class(input, 'error')
      if element_exists?(error_el) && has_class?(error_el, 'error-message')
        error_el.text_content = error_message
        error_el.style.display = 'block'
      end
    else
      remove_class(input, 'error')
      if element_exists?(error_el) && has_class?(error_el, 'error-message')
        error_el.style.display = 'none'
      end
    end
  end
end

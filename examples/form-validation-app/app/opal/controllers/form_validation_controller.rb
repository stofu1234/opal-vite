# backtick_javascript: true
require 'opal_stimulus/stimulus_controller'

class FormValidationController < StimulusController
  include JsProxyEx
  include Toastable
  include DomHelpers

  self.targets = %w[
    field
    error
    submitBtn
    status
    totalFields
    validFields
    invalidFields
    formValid
  ]
  self.values = { submit_url: :string }

  VALIDATION_RULES = {
    required: ->(value) {
      return value if value.is_a?(TrueClass) || value.is_a?(FalseClass)
      value && !value.strip.empty?
    },
    minLength: ->(value, min) {
      !value || value.length >= min.to_i
    },
    maxLength: ->(value, max) {
      !value || value.length <= max.to_i
    },
    email: ->(value) {
      return true unless value
      !!(value =~ /^[^\s@]+@[^\s@]+\.[^\s@]+$/)
    },
    alphanumeric: ->(value) {
      return true unless value
      !!(value =~ /^[a-zA-Z0-9]+$/)
    },
    numeric: ->(value) {
      return true unless value
      !!(value =~ /^\d+(\.\d+)?$/)
    },
    min: ->(value, min_val) {
      return true unless value
      value.to_f >= min_val.to_f
    },
    max: ->(value, max_val) {
      return true unless value
      value.to_f <= max_val.to_f
    },
    password: ->(value) {
      return true unless value
      !!(value =~ /[A-Z]/) && !!(value =~ /[a-z]/) && !!(value =~ /[0-9]/)
    },
    phone: ->(value) {
      return true unless value
      !!(value =~ /^[\d\s\-\+\(\)]+$/) && value.gsub(/\D/, '').length >= 10
    },
    url: ->(value) {
      return true unless value
      begin
        `new URL(#{value})`
        true
      rescue
        false
      end
    }
  }.freeze

  ERROR_MESSAGES = {
    required: 'This field is required',
    minLength: 'Must be at least {0} characters',
    maxLength: 'Must be no more than {0} characters',
    email: 'Please enter a valid email address',
    alphanumeric: 'Only letters and numbers are allowed',
    numeric: 'Please enter a valid number',
    min: 'Value must be at least {0}',
    max: 'Value must be no more than {0}',
    password: 'Must contain uppercase, lowercase, and number',
    phone: 'Please enter a valid phone number',
    url: 'Please enter a valid URL',
    matches: 'This field must match {0}',
    asyncEmailCheck: 'This email is already taken'
  }.freeze

  def initialize
    super
    @validation_state = {}
    @async_validation_in_progress = false
  end

  def connect
    puts '=== FormValidationController connected ==='
    initialize_field_states
    update_stats
  end

  # Stimulus action: validate field on input/blur
  def validate_field(event)
    field = event.current_target
    rules = wrap_js(field.dataset)[:rules]

    unless rules
      clear_field_error(field)
      @validation_state[field_key(field)] = true
      update_stats
      return
    end

    rules_list = rules.split('|')
    is_valid = true
    error_message = ''

    rules_list.each do |rule_str|
      rule_name, rule_param = rule_str.split(':')

      if rule_name == 'asyncEmailCheck'
        validate_email_async(field)
        return
      end

      if rule_name == 'matches'
        target = element.query_selector("[name=\"#{rule_param}\"]")
        if target.to_n
          is_valid = field.value == target.value
          unless is_valid
            error_message = ERROR_MESSAGES[:matches].gsub('{0}', rule_param)
          end
        end
        next unless is_valid
      end

      validator = VALIDATION_RULES[rule_name.to_sym]
      next unless validator

      value = field.type == 'checkbox' ? field.checked : field.value

      unless validator.call(value, rule_param)
        is_valid = false
        error_message = ERROR_MESSAGES[rule_name.to_sym] || 'Invalid'
        error_message = error_message.gsub('{0}', rule_param.to_s) if rule_param
        break
      end
    end

    if is_valid
      clear_field_error(field)
      @validation_state[field_key(field)] = true
    else
      show_field_error(field, error_message)
      @validation_state[field_key(field)] = false
    end

    update_stats
  end

  # Stimulus action: clear error on focus
  def clear_error(event)
    field = event.current_target
    if @validation_state[field_key(field)] == false
      clear_field_error(field)
      @validation_state[field_key(field)] = nil
      update_stats
    end
  end

  # Stimulus action: handle form submit
  def handle_submit(event)
    event.prevent_default

    # Validate all fields
    field_targets.each do |field|
      validate_field_directly(field)
    end

    is_valid = @validation_state.values.all? { |s| s == true }

    unless is_valid
      show_status('Please fix all errors before submitting', 'error')
      return
    end

    form = element.query_selector('form')
    show_status('Submitting form...', 'info')
    submit_btn_target.disabled = true

    # Simulate API call
    set_timeout(1500) do
      puts 'Form submitted successfully'
      show_status('Registration successful! Welcome aboard.', 'success')

      set_timeout(2000) { reset_form }
    end
  end

  # Stimulus action: reset form
  def reset_form
    form = element.query_selector('form')
    form.reset if form.to_n

    @validation_state.clear

    field_targets.each do |field|
      wrapped_field = wrap_js(field)
      clear_field_error(wrapped_field)
      rules = wrapped_field.dataset[:rules]
      @validation_state[field_key(wrapped_field)] = rules ? nil : true
    end

    set_target_text(:status, '')
    set_target_class(:status, 'form-status')

    update_stats
  end

  private

  def field_key(field)
    field.name || field.id || `#{field.to_n}.toString()`
  end

  def initialize_field_states
    targets = field_targets
    len = `#{targets.to_n}.length` rescue 0

    len.to_i.times do |i|
      field = `#{targets.to_n}[#{i}]`
      wrapped_field = JsProxyEx::JsObject.new(field)
      dataset = wrapped_field.dataset
      rules = dataset[:rules] rescue nil
      key = wrapped_field.name || wrapped_field.id || "field_#{i}"
      @validation_state[key] = rules ? nil : true
    end
  end

  def validate_field_directly(field)
    # Wrap field as JsObject if needed
    wrapped_field = field.is_a?(JsProxyEx::JsObject) ? field : wrap_js(field)
    return unless wrapped_field

    # Create a mock event object
    mock_event = Object.new
    mock_event.define_singleton_method(:current_target) { wrapped_field }
    validate_field(mock_event)
  end

  def clear_field_error(field)
    form_group = field.closest('.form-group')
    return unless `#{form_group.to_n} != null`

    remove_class(form_group, 'error')
    remove_class(form_group, 'info')

    error_span = form_group.query_selector('.error-message')
    `#{error_span.to_n} && (#{error_span.to_n}.textContent = '')`
  end

  def show_field_error(field, message, type = 'error')
    form_group = field.closest('.form-group')
    return unless `#{form_group.to_n} != null`

    remove_class(form_group, 'error')
    remove_class(form_group, 'info')
    add_class(form_group, type)

    error_span = form_group.query_selector('.error-message')
    `#{error_span.to_n} && (#{error_span.to_n}.textContent = #{message})`
  end

  def update_stats
    targets = field_targets
    total = `#{targets.to_n}.length`
    valid = @validation_state.values.count { |s| s == true }
    invalid = @validation_state.values.count { |s| s == false }

    all_validated = field_targets.all? { |f| !@validation_state[field_key(f)].nil? }
    form_is_valid = all_validated && invalid == 0 && valid == total

    # Use JsProxyEx helpers for Ruby-like target access
    set_target_text(:total_fields, total.to_s)
    set_target_text(:valid_fields, valid.to_s)
    set_target_text(:invalid_fields, invalid.to_s)
    set_target_text(:form_valid, form_is_valid ? 'Yes' : 'No')
    set_target_class(:form_valid, form_is_valid ? 'stat-value valid' : 'stat-value invalid')
    set_target_disabled(:submit_btn, !form_is_valid || @async_validation_in_progress)
  end

  def show_status(message, type)
    set_target_text(:status, message)
    set_target_class(:status, "form-status #{type}")
  end

  def validate_email_async(field)
    email = field.value
    return unless email && VALIDATION_RULES[:email].call(email)

    @async_validation_in_progress = true
    show_field_error(field, 'Checking email availability...', 'info')

    set_timeout(1000) do
      is_taken = email.downcase == 'test@example.com'

      if is_taken
        show_field_error(field, ERROR_MESSAGES[:asyncEmailCheck])
        @validation_state[field_key(field)] = false
      else
        clear_field_error(field)
        @validation_state[field_key(field)] = true
      end

      @async_validation_in_progress = false
      update_stats
    end
  end
end

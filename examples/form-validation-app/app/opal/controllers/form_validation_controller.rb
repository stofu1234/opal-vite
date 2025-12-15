# backtick_javascript: true
require 'opal_stimulus/stimulus_controller'

class FormValidationController < StimulusController
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

  def connect
    `
      const ctrl = this;
      ctrl.validationState = new Map();
      ctrl.asyncValidationInProgress = false;

      // Define validation rules
      ctrl.validationRules = {
        required: function(value) {
          if (typeof value === 'boolean') return value;
          return value && value.trim().length > 0;
        },

        minLength: function(value, min) {
          return !value || value.length >= parseInt(min);
        },

        maxLength: function(value, max) {
          return !value || value.length <= parseInt(max);
        },

        email: function(value) {
          if (!value) return true;
          const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
          return emailRegex.test(value);
        },

        alphanumeric: function(value) {
          if (!value) return true;
          const alphanumericRegex = /^[a-zA-Z0-9]+$/;
          return alphanumericRegex.test(value);
        },

        numeric: function(value) {
          if (!value) return true;
          return !isNaN(value) && !isNaN(parseFloat(value));
        },

        min: function(value, minVal) {
          if (!value) return true;
          return parseFloat(value) >= parseFloat(minVal);
        },

        max: function(value, maxVal) {
          if (!value) return true;
          return parseFloat(value) <= parseFloat(maxVal);
        },

        password: function(value) {
          if (!value) return true;
          // At least one uppercase, one lowercase, one number
          const hasUppercase = /[A-Z]/.test(value);
          const hasLowercase = /[a-z]/.test(value);
          const hasNumber = /[0-9]/.test(value);
          return hasUppercase && hasLowercase && hasNumber;
        },

        phone: function(value) {
          if (!value) return true;
          // Basic phone validation (flexible format)
          const phoneRegex = /^[\d\s\-\+\(\)]+$/;
          return phoneRegex.test(value) && value.replace(/\D/g, '').length >= 10;
        },

        url: function(value) {
          if (!value) return true;
          try {
            new URL(value);
            return true;
          } catch {
            return false;
          }
        },

        matches: function(value, targetFieldName) {
          const targetField = ctrl.element.querySelector('[name="' + targetFieldName + '"]');
          if (!targetField) return true;
          return value === targetField.value;
        }
      };

      // Define error messages
      ctrl.errorMessages = {
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
      };

      // Initialize validation state
      ctrl.fieldTargets.forEach(function(field) {
        ctrl.validationState.set(field, null);
      });

      ctrl.updateStats();
    `
  end

  def validate_field(event)
    `
      const ctrl = this;
      const field = event.target;
      const rules = field.dataset.rules;

      if (!rules) {
        ctrl.clearFieldError(field);
        ctrl.validationState.set(field, true);
        ctrl.updateStats();
        return;
      }

      const rulesList = rules.split('|');
      let isValid = true;
      let errorMessage = '';

      for (let i = 0; i < rulesList.length; i++) {
        const rule = rulesList[i];
        const [ruleName, ruleParam] = rule.split(':');

        if (ruleName === 'asyncEmailCheck') {
          ctrl.validateEmailAsync(field);
          return;
        }

        const validator = ctrl.validationRules[ruleName];
        if (!validator) continue;

        const value = field.type === 'checkbox' ? field.checked : field.value;

        if (!validator(value, ruleParam)) {
          isValid = false;
          errorMessage = ctrl.errorMessages[ruleName];
          if (ruleParam) {
            errorMessage = errorMessage.replace('{0}', ruleParam);
          }
          break;
        }
      }

      if (isValid) {
        ctrl.clearFieldError(field);
        ctrl.validationState.set(field, true);
      } else {
        ctrl.showFieldError(field, errorMessage);
        ctrl.validationState.set(field, false);
      }

      ctrl.updateStats();
    `
  end

  def validate_email_async(field)
    `
      const ctrl = this;
      const email = field.value;

      if (!email || !ctrl.validationRules.email(email)) {
        return;
      }

      ctrl.asyncValidationInProgress = true;
      ctrl.showFieldError(field, 'Checking email availability...', 'info');

      // Simulate API call
      setTimeout(function() {
        // Simulate that test@example.com is taken
        const isTaken = email.toLowerCase() === 'test@example.com';

        if (isTaken) {
          ctrl.showFieldError(field, ctrl.errorMessages.asyncEmailCheck);
          ctrl.validationState.set(field, false);
        } else {
          ctrl.clearFieldError(field);
          ctrl.validationState.set(field, true);
        }

        ctrl.asyncValidationInProgress = false;
        ctrl.updateStats();
      }, 1000);
    `
  end

  def clear_error(event)
    `
      const ctrl = this;
      const field = event.target;

      if (ctrl.validationState.get(field) === false) {
        ctrl.clearFieldError(field);
        ctrl.validationState.set(field, null);
        ctrl.updateStats();
      }
    `
  end

  def clear_field_error(field)
    `
      const ctrl = this;
      const targetField = arguments[0];
      const formGroup = targetField.closest('.form-group');

      if (formGroup) {
        formGroup.classList.remove('error', 'info');
        const errorSpan = formGroup.querySelector('.error-message');
        if (errorSpan) {
          errorSpan.textContent = '';
        }
      }
    `
  end

  def show_field_error(field, message, type = 'error')
    `
      const ctrl = this;
      const targetField = arguments[0];
      const errorMsg = arguments[1];
      const errorType = arguments[2] || 'error';
      const formGroup = targetField.closest('.form-group');

      if (formGroup) {
        formGroup.classList.remove('error', 'info');
        formGroup.classList.add(errorType);
        const errorSpan = formGroup.querySelector('.error-message');
        if (errorSpan) {
          errorSpan.textContent = errorMsg;
        }
      }
    `
  end

  def update_stats
    `
      const ctrl = this;

      const total = ctrl.fieldTargets.length;
      let valid = 0;
      let invalid = 0;

      ctrl.validationState.forEach(function(state) {
        if (state === true) valid++;
        if (state === false) invalid++;
      });

      if (ctrl.hasTotalFieldsTarget) {
        ctrl.totalFieldsTarget.textContent = total;
      }
      if (ctrl.hasValidFieldsTarget) {
        ctrl.validFieldsTarget.textContent = valid;
      }
      if (ctrl.hasInvalidFieldsTarget) {
        ctrl.invalidFieldsTarget.textContent = invalid;
      }

      // Form is valid if all fields are validated and all are valid
      const allFieldsValidated = ctrl.fieldTargets.every(function(field) {
        const state = ctrl.validationState.get(field);
        return state !== null;
      });

      const formIsValid = allFieldsValidated && invalid === 0 && valid === total;

      if (ctrl.hasFormValidTarget) {
        ctrl.formValidTarget.textContent = formIsValid ? 'Yes' : 'No';
        ctrl.formValidTarget.className = formIsValid ? 'stat-value valid' : 'stat-value invalid';
      }

      if (ctrl.hasSubmitBtnTarget) {
        ctrl.submitBtnTarget.disabled = !formIsValid || ctrl.asyncValidationInProgress;
      }
    `
  end

  def handle_submit(event)
    `
      const ctrl = this;
      event.preventDefault();

      // Validate all fields
      ctrl.fieldTargets.forEach(function(field) {
        const fakeEvent = { target: field };
        ctrl.validateField(fakeEvent);
      });

      // Check if form is valid
      const isValid = Array.from(ctrl.validationState.values()).every(function(state) {
        return state === true;
      });

      if (!isValid) {
        ctrl.showStatus('Please fix all errors before submitting', 'error');
        return;
      }

      // Collect form data
      const formData = new FormData(ctrl.element);
      const data = Object.fromEntries(formData.entries());

      ctrl.showStatus('Submitting form...', 'info');
      ctrl.submitBtnTarget.disabled = true;

      // Simulate API call
      setTimeout(function() {
        console.log('Form submitted:', data);
        ctrl.showStatus('Registration successful! Welcome aboard.', 'success');

        // Reset form after 2 seconds
        setTimeout(function() {
          ctrl.resetForm();
        }, 2000);
      }, 1500);
    `
  end

  def reset_form
    `
      const ctrl = this;
      ctrl.element.reset();
      ctrl.validationState.clear();

      ctrl.fieldTargets.forEach(function(field) {
        ctrl.clearFieldError(field);
        ctrl.validationState.set(field, null);
      });

      if (ctrl.hasStatusTarget) {
        ctrl.statusTarget.textContent = '';
        ctrl.statusTarget.className = 'form-status';
      }

      ctrl.updateStats();
    `
  end

  def show_status(message, type)
    `
      const ctrl = this;
      const statusMsg = arguments[0];
      const statusType = arguments[1];

      if (ctrl.hasStatusTarget) {
        ctrl.statusTarget.textContent = statusMsg;
        ctrl.statusTarget.className = 'form-status ' + statusType;
      }
    `
  end
end

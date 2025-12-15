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
    # All logic defined as JavaScript methods on the controller instance
    `
      console.log('=== CONNECT METHOD STARTED ===');
      const ctrl = this;
      ctrl.validationState = new Map();
      ctrl.asyncValidationInProgress = false;
      console.log('Initialized validationState and asyncValidationInProgress');

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
          return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
        },
        alphanumeric: function(value) {
          if (!value) return true;
          return /^[a-zA-Z0-9]+$/.test(value);
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
          return /[A-Z]/.test(value) && /[a-z]/.test(value) && /[0-9]/.test(value);
        },
        phone: function(value) {
          if (!value) return true;
          return /^[\d\s\-\+\(\)]+$/.test(value) && value.replace(/\D/g, '').length >= 10;
        },
        url: function(value) {
          if (!value) return true;
          try { new URL(value); return true; } catch { return false; }
        },
        matches: function(value, targetFieldName) {
          const target = ctrl.element.querySelector('[name="' + targetFieldName + '"]');
          return !target || value === target.value;
        }
      };

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

      // Store method references for Stimulus actions
      this.validate_field = function(event) {
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
          const [ruleName, ruleParam] = rulesList[i].split(':');

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
      };

      this.clear_error = function(event) {
        const field = event.target;
        if (ctrl.validationState.get(field) === false) {
          ctrl.clearFieldError(field);
          ctrl.validationState.set(field, null);
          ctrl.updateStats();
        }
      };

      this.handle_submit = function(event) {
        event.preventDefault();

        // Validate all fields
        ctrl.fieldTargets.forEach(function(field) {
          ctrl.validate_field({ target: field });
        });

        const isValid = Array.from(ctrl.validationState.values()).every(s => s === true);

        if (!isValid) {
          ctrl.showStatus('Please fix all errors before submitting', 'error');
          return;
        }

        const form = ctrl.element.querySelector('form');
        const formData = new FormData(form);
        const data = Object.fromEntries(formData.entries());

        ctrl.showStatus('Submitting form...', 'info');
        ctrl.submitBtnTarget.disabled = true;

        setTimeout(function() {
          console.log('Form submitted:', data);
          ctrl.showStatus('Registration successful! Welcome aboard.', 'success');

          setTimeout(function() { ctrl.reset_form(); }, 2000);
        }, 1500);
      };

      this.reset_form = function() {
        const form = ctrl.element.querySelector('form');
        if (form) form.reset();
        ctrl.validationState.clear();

        ctrl.fieldTargets.forEach(function(field) {
          ctrl.clearFieldError(field);
          // Re-initialize: fields without rules are valid, others are null
          if (!field.dataset.rules) {
            ctrl.validationState.set(field, true);
          } else {
            ctrl.validationState.set(field, null);
          }
        });

        if (ctrl.hasStatusTarget) {
          ctrl.statusTarget.textContent = '';
          ctrl.statusTarget.className = 'form-status';
        }

        ctrl.updateStats();
      };

      ctrl.clearFieldError = function(field) {
        const formGroup = field.closest('.form-group');
        if (formGroup) {
          formGroup.classList.remove('error', 'info');
          const errorSpan = formGroup.querySelector('.error-message');
          if (errorSpan) errorSpan.textContent = '';
        }
      };

      ctrl.showFieldError = function(field, message, type) {
        type = type || 'error';
        const formGroup = field.closest('.form-group');
        if (formGroup) {
          formGroup.classList.remove('error', 'info');
          formGroup.classList.add(type);
          const errorSpan = formGroup.querySelector('.error-message');
          if (errorSpan) errorSpan.textContent = message;
        }
      };

      ctrl.updateStats = function() {
        const total = ctrl.fieldTargets.length;
        let valid = 0, invalid = 0;

        ctrl.validationState.forEach(function(state) {
          if (state === true) valid++;
          if (state === false) invalid++;
        });

        console.log('updateStats - total:', total, 'valid:', valid, 'invalid:', invalid);
        console.log('hasTotalFieldsTarget:', ctrl.hasTotalFieldsTarget);
        console.log('totalFieldsTarget:', ctrl.totalFieldsTarget);

        if (ctrl.hasTotalFieldsTarget) ctrl.totalFieldsTarget.textContent = total;
        if (ctrl.hasValidFieldsTarget) ctrl.validFieldsTarget.textContent = valid;
        if (ctrl.hasInvalidFieldsTarget) ctrl.invalidFieldsTarget.textContent = invalid;

        const allValidated = ctrl.fieldTargets.every(f => ctrl.validationState.get(f) !== null);
        const formIsValid = allValidated && invalid === 0 && valid === total;

        if (ctrl.hasFormValidTarget) {
          ctrl.formValidTarget.textContent = formIsValid ? 'Yes' : 'No';
          ctrl.formValidTarget.className = formIsValid ? 'stat-value valid' : 'stat-value invalid';
        }

        if (ctrl.hasSubmitBtnTarget) {
          ctrl.submitBtnTarget.disabled = !formIsValid || ctrl.asyncValidationInProgress;
        }
      };

      ctrl.showStatus = function(message, type) {
        if (ctrl.hasStatusTarget) {
          ctrl.statusTarget.textContent = message;
          ctrl.statusTarget.className = 'form-status ' + type;
        }
      };

      ctrl.validateEmailAsync = function(field) {
        const email = field.value;
        if (!email || !ctrl.validationRules.email(email)) return;

        ctrl.asyncValidationInProgress = true;
        ctrl.showFieldError(field, 'Checking email availability...', 'info');

        setTimeout(function() {
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
      };

      // Initialize
      console.log('fieldTargets:', ctrl.fieldTargets);
      console.log('fieldTargets.length:', ctrl.fieldTargets.length);

      try {
        console.log('Before forEach...');
        ctrl.fieldTargets.forEach(function(f) {
          // Fields without rules are automatically valid
          if (!f.dataset.rules) {
            ctrl.validationState.set(f, true);
          } else {
            ctrl.validationState.set(f, null);
          }
        });
        console.log('After forEach, before updateStats...');
        ctrl.updateStats();
        console.log('After updateStats');
      } catch (error) {
        console.error('Error in initialization:', error);
      }
    `
  end
end

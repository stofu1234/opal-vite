# backtick_javascript: true

# Form validation controller with real-time feedback
class FormController < StimulusController
  self.targets = ["input", "error"]

  def connect
    puts "Form controller connected!"
  end

  # Validate on input
  def validate
    `
      const input = event.currentTarget;
      const errorEl = input.nextElementSibling;
      const value = input.value.trim();

      // Get validation rules from data attributes
      const required = input.hasAttribute('data-required');
      const minLength = parseInt(input.getAttribute('data-min-length') || '0');
      const maxLength = parseInt(input.getAttribute('data-max-length') || '1000');
      const pattern = input.getAttribute('data-pattern');

      let errorMessage = '';

      // Required validation
      if (required && value === '') {
        errorMessage = 'This field is required';
      }
      // Min length validation
      else if (minLength > 0 && value.length < minLength) {
        errorMessage = 'Must be at least ' + minLength + ' characters';
      }
      // Max length validation
      else if (maxLength > 0 && value.length > maxLength) {
        errorMessage = 'Must be at most ' + maxLength + ' characters';
      }
      // Pattern validation
      else if (pattern && value !== '') {
        const regex = new RegExp(pattern);
        if (!regex.test(value)) {
          errorMessage = 'Invalid format';
        }
      }

      // Show/hide error
      if (errorMessage) {
        input.classList.add('error');
        if (errorEl && errorEl.classList.contains('error-message')) {
          errorEl.textContent = errorMessage;
          errorEl.style.display = 'block';
        }
      } else {
        input.classList.remove('error');
        if (errorEl && errorEl.classList.contains('error-message')) {
          errorEl.style.display = 'none';
        }
      }
    `
  end

  # Submit with validation
  def submit
    `
      event.preventDefault();

      // Validate form inline
      const form = this.element;
      const inputs = form.querySelectorAll('[data-form-target="input"]');
      let isValid = true;

      inputs.forEach(input => {
        // Trigger validation for each input
        const validateEvent = new Event('input', { bubbles: true });
        input.dispatchEvent(validateEvent);

        // Check if has error class
        if (input.classList.contains('error')) {
          isValid = false;
        }
      });

      if (!isValid) {
        const toastEvent = new CustomEvent('show-toast', {
          detail: { message: 'Please fix validation errors', type: 'error' }
        });
        window.dispatchEvent(toastEvent);
        return;
      }

      // Form is valid, proceed with submission
      console.log('Form is valid, submitting...');

      // Show success toast
      const successEvent = new CustomEvent('show-toast', {
        detail: { message: 'Form submitted successfully!', type: 'success' }
      });
      window.dispatchEvent(successEvent);

      // Reset form
      this.element.reset();

      // Clear all error states
      inputs.forEach(input => {
        input.classList.remove('error');
        const errorEl = input.nextElementSibling;
        if (errorEl && errorEl.classList.contains('error-message')) {
          errorEl.style.display = 'none';
        }
      });
    `
  end
end

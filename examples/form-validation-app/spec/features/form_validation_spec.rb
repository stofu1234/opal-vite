# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe 'Form Validation', type: :feature do
  describe 'page layout' do
    it 'displays the main header' do
      expect(page).to have_css('header h1', text: 'Form Validation Example')
    end

    it 'displays the registration form' do
      expect(page).to have_css('form')
      expect(page).to have_css('h2', text: 'User Registration')
    end

    it 'displays validation stats' do
      expect(page).to have_css('.stats-card h3', text: 'Validation Stats')
      expect(page).to have_css('[data-form-validation-target="totalFields"]')
    end

    it 'displays features section' do
      expect(page).to have_css('.info-card h3', text: 'Features Demonstrated')
    end

    it 'displays the footer' do
      expect(page).to have_css('footer')
      expect(page).to have_link('Opal')
      expect(page).to have_link('Stimulus')
      expect(page).to have_link('Vite')
    end
  end

  describe 'form fields' do
    it 'has all required input fields' do
      expect(page).to have_field('name', type: 'text')
      expect(page).to have_field('email', type: 'email')
      expect(page).to have_field('username', type: 'text')
      expect(page).to have_field('password', type: 'password')
      expect(page).to have_field('confirmPassword', type: 'password')
      expect(page).to have_field('age', type: 'number')
      expect(page).to have_field('phone', type: 'tel')
      expect(page).to have_field('website', type: 'url')
    end

    it 'has country select field' do
      expect(page).to have_select('country', with_options: ['Select a country', 'United States', 'Japan'])
    end

    it 'has terms and newsletter checkboxes' do
      expect(page).to have_field('terms', type: 'checkbox')
      expect(page).to have_field('newsletter', type: 'checkbox')
    end

    it 'has submit and reset buttons' do
      # Register button exists (may be disabled initially)
      expect(page).to have_button('Register', disabled: true)
      expect(page).to have_button('Reset')
    end
  end

  describe 'required field validation' do
    it 'shows error when name is empty' do
      fill_and_blur('#name', '')
      expect(page).to have_css('.form-group.error', text: 'This field is required')
    end

    it 'shows error when email is empty' do
      fill_and_blur('#email', '')
      expect(page).to have_css('.form-group.error', text: 'This field is required')
    end

    it 'shows error when username is empty' do
      fill_and_blur('#username', '')
      expect(page).to have_css('.form-group.error', text: 'This field is required')
    end
  end

  describe 'name field validation' do
    it 'shows error when name is too short' do
      fill_and_blur('#name', 'ab')
      expect(page).to have_css('.form-group.error', text: 'at least 3 characters')
    end

    it 'accepts valid name' do
      fill_and_blur('#name', 'John Doe')
      expect(page).to have_no_css('#name ~ .error-message', text: 'required')
    end
  end

  describe 'email field validation' do
    it 'shows error for invalid email format' do
      fill_and_blur('#email', 'invalid-email')
      expect(page).to have_css('.form-group.error', text: 'valid email address')
    end

    it 'accepts valid email' do
      fill_and_blur('#email', 'user@example.com')
      # Wait for async validation
      sleep 1.5
      wait_for_dom_stable
      expect(page).to have_no_css('.form-group.error #email')
    end

    it 'shows error for already taken email' do
      fill_and_blur('#email', 'test@example.com')
      # Wait for async validation
      sleep 1.5
      wait_for_dom_stable
      expect(page).to have_css('.form-group.error', text: 'already taken')
    end
  end

  describe 'username field validation' do
    it 'shows error for username with special characters' do
      fill_and_blur('#username', 'user@name!')
      expect(page).to have_css('.form-group.error', text: 'letters and numbers')
    end

    it 'shows error for username too short' do
      fill_and_blur('#username', 'abc')
      expect(page).to have_css('.form-group.error', text: 'at least 4 characters')
    end

    it 'accepts valid username' do
      fill_and_blur('#username', 'validuser123')
      expect(page).to have_no_css('.form-group.error #username')
    end
  end

  describe 'password field validation' do
    it 'shows error for password too short' do
      fill_and_blur('#password', 'short')
      expect(page).to have_css('.form-group.error', text: 'at least 8 characters')
    end

    it 'shows error for password without uppercase' do
      fill_and_blur('#password', 'lowercase123')
      expect(page).to have_css('.form-group.error', text: 'uppercase, lowercase, and number')
    end

    it 'shows error for password without number' do
      fill_and_blur('#password', 'NoNumberPass')
      expect(page).to have_css('.form-group.error', text: 'uppercase, lowercase, and number')
    end

    it 'accepts valid password' do
      fill_and_blur('#password', 'ValidPass123')
      expect(page).to have_no_css('.form-group.error #password')
    end
  end

  describe 'confirm password validation' do
    it 'shows error when passwords do not match' do
      fill_and_blur('#password', 'ValidPass123')
      fill_and_blur('#confirmPassword', 'DifferentPass456')
      expect(page).to have_css('.form-group.error', text: 'must match')
    end

    it 'accepts matching passwords' do
      fill_and_blur('#password', 'ValidPass123')
      fill_and_blur('#confirmPassword', 'ValidPass123')
      expect(page).to have_no_css('.form-group.error #confirmPassword')
    end
  end

  describe 'age field validation' do
    it 'shows error for age below minimum' do
      fill_and_blur('#age', '16')
      expect(page).to have_css('.form-group.error', text: 'at least 18')
    end

    it 'shows error for age above maximum' do
      fill_and_blur('#age', '150')
      expect(page).to have_css('.form-group.error', text: 'no more than 120')
    end

    it 'accepts valid age' do
      fill_and_blur('#age', '25')
      expect(page).to have_no_css('.form-group.error #age')
    end
  end

  describe 'phone field validation' do
    it 'shows error for invalid phone format' do
      fill_and_blur('#phone', 'abc123')
      expect(page).to have_css('.form-group.error', text: 'valid phone number')
    end

    it 'accepts valid phone number' do
      fill_and_blur('#phone', '+1 (555) 123-4567')
      expect(page).to have_no_css('.form-group.error #phone')
    end
  end

  describe 'website field validation' do
    it 'accepts valid URL' do
      fill_and_blur('#website', 'https://example.com')
      expect(page).to have_no_css('.form-group.error #website')
    end

    it 'accepts empty URL (optional field)' do
      fill_and_blur('#website', '')
      expect(page).to have_no_css('.form-group.error #website')
    end
  end

  describe 'country select validation' do
    it 'shows error when no country selected' do
      find('#country').select('Select a country')
      page.execute_script("document.querySelector('#country').dispatchEvent(new Event('change', { bubbles: true }))")
      sleep 0.3
      wait_for_dom_stable
      expect(page).to have_css('.form-group.error', text: 'required')
    end

    it 'accepts valid country selection' do
      find('#country').select('Japan')
      page.execute_script("document.querySelector('#country').dispatchEvent(new Event('change', { bubbles: true }))")
      sleep 0.3
      wait_for_dom_stable
      expect(page).to have_no_css('.form-group.error #country')
    end
  end

  describe 'terms checkbox validation' do
    it 'shows error when terms not accepted' do
      # Find the terms checkbox and click it (to make sure change event fires)
      find('input[name="terms"]').click
      sleep 0.3
      find('input[name="terms"]').click
      sleep 0.3
      wait_for_dom_stable
      expect(page).to have_css('.form-group.error', text: 'required')
    end

    it 'accepts when terms are accepted' do
      find('input[name="terms"]').click
      sleep 0.3
      wait_for_dom_stable
      expect(page).to have_no_css('.form-group.error input[name="terms"]')
    end
  end

  describe 'validation stats' do
    it 'displays total fields count' do
      total = find('[data-form-validation-target="totalFields"]').text.to_i
      expect(total).to be > 0
    end

    it 'updates valid fields count when validating' do
      fill_and_blur('#name', 'John Doe')

      valid_count = find('[data-form-validation-target="validFields"]').text.to_i
      expect(valid_count).to be >= 1
    end

    it 'updates invalid fields count on error' do
      fill_and_blur('#name', 'ab')

      invalid_count = find('[data-form-validation-target="invalidFields"]').text.to_i
      expect(invalid_count).to be >= 1
    end

    it 'shows form valid status as No initially' do
      expect(page).to have_css('[data-form-validation-target="formValid"]', text: 'No')
    end
  end

  describe 'clear error on input' do
    it 'clears error when typing after validation error' do
      fill_and_blur('#name', 'ab')
      expect(page).to have_css('.form-group.error', text: 'at least 3')

      # Type more to clear error
      find('#name').send_keys('c')
      sleep 0.3
      wait_for_dom_stable

      # Error should be cleared (but not validated until blur)
      form_group = find('#name').ancestor('.form-group')
      expect(form_group[:class]).not_to include('error')
    end
  end

  describe 'reset form' do
    it 'clears all fields and errors when reset is clicked' do
      # Fill some fields with errors
      fill_and_blur('#name', 'ab')
      fill_and_blur('#email', 'invalid')
      expect(page).to have_css('.form-group.error')

      # Click reset
      stable_click('button[data-action="click->form-validation#reset_form"]')
      sleep 0.5
      wait_for_dom_stable

      # Errors should be cleared
      expect(page).to have_no_css('.form-group.error')

      # Fields should be empty
      expect(find('#name').value).to eq('')
      expect(find('#email').value).to eq('')
    end
  end
end

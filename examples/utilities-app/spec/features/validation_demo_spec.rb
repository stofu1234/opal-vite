# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Validation Demo', type: :feature do
  describe 'Email validation' do
    it 'validates valid email on input' do
      stable_set('[data-validation-demo-target="emailInput"]', 'user@example.com')

      page.execute_script(<<~JS)
        document.querySelector('[data-validation-demo-target="emailInput"]').dispatchEvent(new Event('input', { bubbles: true }));
      JS

      wait_for_dom_stable
      output = find('[data-validation-demo-target="output"]')

      expect(output).to have_content('Valid')
    end
  end

  describe 'URL validation' do
    it 'validates valid URL on input' do
      stable_set('[data-validation-demo-target="urlInput"]', 'https://example.com')

      page.execute_script(<<~JS)
        document.querySelector('[data-validation-demo-target="urlInput"]').dispatchEvent(new Event('input', { bubbles: true }));
      JS

      wait_for_dom_stable
      output = find('[data-validation-demo-target="output"]')

      expect(output).to have_content('Valid')
    end
  end

  describe 'Phone validation' do
    it 'validates phone number on input' do
      stable_set('[data-validation-demo-target="phoneInput"]', '+81901234567')

      page.execute_script(<<~JS)
        document.querySelector('[data-validation-demo-target="phoneInput"]').dispatchEvent(new Event('input', { bubbles: true }));
      JS

      wait_for_dom_stable
      output = find('[data-validation-demo-target="output"]')

      expect(output).to have_content('Valid')
    end
  end

  describe 'Blank check' do
    it 'checks if text is blank' do
      stable_set('[data-validation-demo-target="textInput"]', '')
      stable_click('[data-action="click->validation-demo#check_blank"]')

      wait_for_dom_stable
      output = find('[data-validation-demo-target="output"]')

      expect(output).to have_content('blank')
    end
  end

  describe 'Length check' do
    it 'shows text length' do
      stable_set('[data-validation-demo-target="textInput"]', 'Hello World')
      stable_click('[data-action="click->validation-demo#check_length"]')

      wait_for_dom_stable
      output = find('[data-validation-demo-target="output"]')

      expect(output).to have_content('11')
    end
  end

  describe 'Validate all' do
    it 'validates all fields at once' do
      stable_set('[data-validation-demo-target="emailInput"]', 'test@example.com')
      stable_set('[data-validation-demo-target="urlInput"]', 'https://example.com')
      stable_set('[data-validation-demo-target="phoneInput"]', '+15551234')
      stable_click('[data-action="click->validation-demo#validate_all"]')

      wait_for_dom_stable
      output = find('[data-validation-demo-target="output"]')

      expect(output).to have_content('Email')
      expect(output).to have_content('URL')
      expect(output).to have_content('Phone')
    end
  end

  describe 'Pattern matching' do
    it 'checks text against regex pattern' do
      stable_set('[data-validation-demo-target="textInput"]', 'Hello')
      stable_set('[data-validation-demo-target="patternInput"]', '^H')
      stable_click('[data-action="click->validation-demo#check_pattern"]')

      wait_for_dom_stable
      output = find('[data-validation-demo-target="output"]')

      expect(output).to have_content('Matches')
    end
  end
end

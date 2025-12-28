# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Base64 Demo', type: :feature do
  describe 'Basic encoding/decoding' do
    it 'encodes text to Base64' do
      stable_set('[data-base64-demo-target="input"]', 'Hello')
      stable_click('[data-action="click->base64-demo#encode"]')
      sleep 0.3
      wait_for_dom_stable

      output = find('[data-base64-demo-target="output"]')
      # "Hello" encodes to "SGVsbG8="
      expect(output).to have_content('SGVsbG8=')
    end

    it 'decodes Base64 to text' do
      stable_set('[data-base64-demo-target="input"]', 'SGVsbG8=')
      stable_click('[data-action="click->base64-demo#decode"]')
      sleep 0.3
      wait_for_dom_stable

      output = find('[data-base64-demo-target="output"]')
      expect(output).to have_content('Hello')
    end
  end

  describe 'URL-safe Base64' do
    it 'demonstrates URL-safe encoding' do
      stable_click('[data-action="click->base64-demo#urlsafe_demo"]')

      wait_for_dom_stable
      output = find('[data-base64-demo-target="output"]')

      expect(output).to have_content('Standard Base64')
      expect(output).to have_content('URL-safe Base64')
    end
  end

  describe 'Unicode support' do
    it 'encodes and decodes Unicode text' do
      stable_click('[data-action="click->base64-demo#unicode_demo"]')

      wait_for_dom_stable
      output = find('[data-base64-demo-target="output"]')

      expect(output).to have_content('Original')
      expect(output).to have_content('Base64 Encoded')
    end
  end

  describe 'Data URLs' do
    it 'creates and parses data URLs' do
      stable_click('[data-action="click->base64-demo#data_url_demo"]')

      wait_for_dom_stable
      output = find('[data-base64-demo-target="output"]')

      expect(output).to have_content('Data URL')
      expect(output).to have_content('text/html')
    end
  end

  describe 'JWT decoding' do
    it 'decodes JWT payload' do
      stable_click('[data-action="click->base64-demo#decode_jwt"]')

      wait_for_dom_stable
      output = find('[data-base64-demo-target="output"]')

      expect(output).to have_content('Payload')
      expect(output).to have_content('John Doe')
    end
  end

  describe 'Basic Auth' do
    it 'generates Basic Auth header' do
      stable_set('[data-base64-demo-target="authUser"]', 'testuser')
      stable_set('[data-base64-demo-target="authPass"]', 'testpass')
      stable_click('[data-action="click->base64-demo#basic_auth_demo"]')

      wait_for_dom_stable
      output = find('[data-base64-demo-target="output"]')

      expect(output).to have_content('Basic ')
      expect(output).to have_content('testuser')
    end

    it 'uses default credentials when empty' do
      stable_click('[data-action="click->base64-demo#basic_auth_demo"]')

      wait_for_dom_stable
      output = find('[data-base64-demo-target="output"]')

      expect(output).to have_content('admin')
    end
  end

  describe 'Base64 validation' do
    it 'validates Base64 strings' do
      stable_set('[data-base64-demo-target="input"]', 'SGVsbG8=')
      stable_click('[data-action="click->base64-demo#validate_base64"]')

      wait_for_dom_stable
      output = find('[data-base64-demo-target="output"]')

      expect(output).to have_content('Valid Base64')
    end
  end
end

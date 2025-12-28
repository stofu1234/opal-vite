# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'URL Demo', type: :feature do
  describe 'URL parsing' do
    it 'parses a URL and shows components' do
      stable_set('[data-url-demo-target="urlInput"]', 'https://example.com:8080/path?query=value#hash')
      stable_click('[data-action="click->url-demo#parse"]')

      wait_for_dom_stable
      output = find('[data-url-demo-target="output"]')

      expect(output).to have_content('Protocol')
      expect(output).to have_content('example.com')
      expect(output).to have_content('8080')
      expect(output).to have_content('/path')
    end

    it 'parses current page URL' do
      stable_click('[data-action="click->url-demo#parse_current"]')

      wait_for_dom_stable
      output = find('[data-url-demo-target="output"]')

      expect(output).to have_content('Protocol')
      expect(output).to have_content('localhost')
    end
  end

  describe 'URL building' do
    it 'builds a URL from components' do
      stable_click('[data-action="click->url-demo#build_example"]')

      wait_for_dom_stable
      input = find('[data-url-demo-target="urlInput"]')

      expect(input.value).to include('api.example.com')
      expect(input.value).to include('/v1/users')
    end
  end

  describe 'Query parameters' do
    it 'adds query parameters' do
      stable_set('[data-url-demo-target="urlInput"]', 'https://example.com/path')
      stable_set('[data-url-demo-target="paramKey"]', 'foo')
      stable_set('[data-url-demo-target="paramValue"]', 'bar')
      stable_click('[data-action="click->url-demo#add_param"]')

      wait_for_dom_stable
      input = find('[data-url-demo-target="urlInput"]')

      expect(input.value).to include('foo=bar')
    end
  end

  describe 'URL encoding' do
    it 'demonstrates encoding and decoding' do
      stable_click('[data-action="click->url-demo#encode_demo"]')

      wait_for_dom_stable
      output = find('[data-url-demo-target="output"]')

      expect(output).to have_content('Original')
      expect(output).to have_content('Encoded')
    end
  end

  describe 'Query string parsing' do
    it 'parses and builds query strings' do
      stable_click('[data-action="click->url-demo#query_string_demo"]')

      wait_for_dom_stable
      output = find('[data-url-demo-target="output"]')

      expect(output).to have_content('name')
    end
  end
end

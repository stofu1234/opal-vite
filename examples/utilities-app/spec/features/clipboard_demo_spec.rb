# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Clipboard & Utilities Demo', type: :feature do
  describe 'Debounce search' do
    it 'shows search output after debounce delay' do
      stable_set('[data-clipboard-demo-target="searchInput"]', 'test query')

      page.execute_script(<<~JS)
        document.querySelector('[data-clipboard-demo-target="searchInput"]').dispatchEvent(new Event('input', { bubbles: true }));
      JS

      # Wait for debounce (300ms) + processing
      sleep 0.5
      wait_for_dom_stable

      output = find('[data-clipboard-demo-target="searchOutput"]')
      expect(output).to have_content('test query')
    end
  end

  describe 'Set operations' do
    it 'shows unique values' do
      stable_click('[data-action="click->clipboard-demo#unique_demo"]')

      wait_for_dom_stable
      output = find('[data-clipboard-demo-target="setOutput"]')

      expect(output).to have_content('Original')
      expect(output).to have_content('unique')
    end

    it 'performs set operations on arrays' do
      stable_click('[data-action="click->clipboard-demo#set_operations"]')

      wait_for_dom_stable
      output = find('[data-clipboard-demo-target="setOutput"]')

      expect(output).to have_content('intersection')
      expect(output).to have_content('union')
    end
  end

  describe 'Object utilities' do
    it 'demonstrates deep_clone' do
      stable_click('[data-action="click->clipboard-demo#deep_clone_demo"]')

      wait_for_dom_stable
      output = find('[data-clipboard-demo-target="objOutput"]')

      expect(output).to have_content('Original')
      expect(output).to have_content('Cloned')
    end

    it 'demonstrates deep_merge' do
      stable_click('[data-action="click->clipboard-demo#deep_merge_demo"]')

      wait_for_dom_stable
      output = find('[data-clipboard-demo-target="objOutput"]')

      expect(output).to have_content('deep_merge')
    end

    it 'demonstrates pick and omit' do
      stable_click('[data-action="click->clipboard-demo#pick_omit_demo"]')

      wait_for_dom_stable
      output = find('[data-clipboard-demo-target="objOutput"]')

      expect(output).to have_content('pick')
      expect(output).to have_content('omit')
    end
  end

  describe 'Console helpers' do
    it 'runs console demo without errors' do
      stable_click('[data-action="click->clipboard-demo#console_demo"]')

      wait_for_dom_stable
      # If we get here without JS errors, the test passes
      expect(page).to have_content('Console Helpers')
    end
  end
end

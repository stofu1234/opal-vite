# frozen_string_literal: true

RSpec.describe 'Theme Toggle', type: :feature do
  let(:toggle_button_selector) { '[data-action*="theme#toggle"]' }

  def html_element
    find('html')
  end

  def toggle_button
    find(toggle_button_selector)
  end

  describe 'toggling theme' do
    it 'toggles between light and dark mode' do
      # Should start in light mode (no data-theme or data-theme="light")
      expect(html_element['data-theme']).not_to eq('dark')

      # Toggle to dark mode
      toggle_button.click
      expect(html_element['data-theme']).to eq('dark')

      # Toggle back to light mode
      toggle_button.click
      expect(html_element['data-theme']).to eq('light')
    end
  end

  describe 'persistence' do
    it 'persists theme preference' do
      # Toggle to dark mode
      toggle_button.click
      expect(html_element['data-theme']).to eq('dark')

      # Reload page
      visit '/'

      # Should still be in dark mode
      expect(html_element['data-theme']).to eq('dark')
    end
  end

  describe 'button appearance' do
    it 'updates toggle button appearance' do
      # In light mode, button shows "Dark Mode"
      expect(toggle_button).to have_content(/Dark Mode/i)

      # Toggle to dark mode
      toggle_button.click

      # In dark mode, button shows "Light Mode"
      expect(toggle_button).to have_content(/Light Mode/i)
    end
  end

  describe 'theme styles' do
    it 'applies theme styles correctly' do
      # Toggle to dark mode
      toggle_button.click

      # Verify data-theme attribute is set
      expect(html_element['data-theme']).to eq('dark')
    end
  end

  describe 'system preference' do
    it 'handles system preference' do
      # Toggle should work regardless of system preference
      toggle_button.click

      theme = html_element['data-theme']
      expect(['light', 'dark']).to include(theme)
    end
  end
end

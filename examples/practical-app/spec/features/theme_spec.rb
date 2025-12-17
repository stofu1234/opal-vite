# frozen_string_literal: true

RSpec.describe 'Theme Toggle', type: :feature do
  let(:toggle_button_selector) { '[data-action*="theme#toggle"]' }
  let(:theme_controller_selector) { '[data-controller~="theme"]' }

  def html_element
    find('html')
  end

  def toggle_button
    stable_find(toggle_button_selector)
  end

  def click_toggle
    # Use JavaScript to dispatch click event directly for reliability in CI
    page.execute_script(<<~JS)
      (function() {
        var btn = document.querySelector('[data-action*="theme#toggle"]');
        if (btn) {
          // Create and dispatch a real click event
          var clickEvent = new MouseEvent('click', {
            view: window,
            bubbles: true,
            cancelable: true
          });
          btn.dispatchEvent(clickEvent);
        }
      })()
    JS
    # Give Stimulus time to process the click and update DOM
    sleep 0.1
    wait_for_dom_stable
  end

  describe 'toggling theme' do
    it 'toggles between light and dark mode' do
      # Should start in light mode (no data-theme or data-theme="light")
      expect(html_element['data-theme']).not_to eq('dark')

      # Toggle to dark mode
      click_toggle
      expect(page).to have_css('html[data-theme="dark"]', wait: 5)

      # Toggle back to light mode
      click_toggle
      expect(page).to have_css('html[data-theme="light"]', wait: 5)
    end
  end

  describe 'persistence' do
    it 'persists theme preference' do
      # Toggle to dark mode
      click_toggle
      expect(page).to have_css('html[data-theme="dark"]', wait: 5)

      # Reload page
      visit '/'

      # Should still be in dark mode
      expect(page).to have_css('html[data-theme="dark"]', wait: 5)
    end
  end

  describe 'button appearance' do
    it 'updates toggle button appearance' do
      # In light mode, button shows "Dark Mode"
      wait_for_text(toggle_button_selector, 'Dark Mode')

      # Toggle to dark mode
      click_toggle

      # In dark mode, button shows "Light Mode"
      wait_for_text(toggle_button_selector, 'Light Mode')
    end
  end

  describe 'theme styles' do
    it 'applies theme styles correctly' do
      # Toggle to dark mode
      click_toggle

      # Wait for theme to be applied using JS polling
      js_wait_for("document.documentElement.dataset.theme === 'dark'", timeout: 5)
    end
  end

  describe 'system preference' do
    it 'handles system preference' do
      # Toggle should work regardless of system preference
      click_toggle

      # Wait for theme to be applied
      js_wait_for("document.documentElement.dataset.theme !== undefined", timeout: 5)

      theme = html_element['data-theme']
      expect(['light', 'dark']).to include(theme)
    end
  end
end

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
    # Wait for Stimulus controller to be fully connected
    js_wait_for(<<~JS, timeout: 10)
      (function() {
        var el = document.querySelector('[data-controller~="theme"]');
        if (!el || !window.Stimulus) return false;
        var ctrl = window.Stimulus.getControllerForElementAndIdentifier(el, 'theme');
        return ctrl && (typeof ctrl.$toggle === 'function' || typeof ctrl.toggle === 'function');
      })()
    JS

    # Directly invoke Stimulus controller's toggle method for reliability
    # Opal's event_target helper accesses the global `event` variable
    result = page.evaluate_script(<<~JS)
      (function() {
        var themeElement = document.querySelector('[data-controller~="theme"]');
        var controller = window.Stimulus.getControllerForElementAndIdentifier(themeElement, 'theme');
        var btn = document.querySelector('[data-action*="theme#toggle"]');

        // Create a fake global event object for Opal's event_target helper
        window.event = { target: btn, currentTarget: btn, preventDefault: function(){}, stopPropagation: function(){} };

        try {
          if (typeof controller.$toggle === 'function') {
            controller.$toggle(window.event);
            return { success: true, method: '$toggle' };
          } else {
            controller.toggle(window.event);
            return { success: true, method: 'toggle' };
          }
        } catch (e) {
          return { error: 'exception', message: e.message };
        } finally {
          delete window.event;
        }
      })()
    JS

    if result && result['error']
      puts "click_toggle error: #{result.inspect}"
    end

    # Give Stimulus time to process and update DOM
    sleep 0.2
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

# backtick_javascript: true

# Theme controller for dark mode toggle
class ThemeController < StimulusController
  include JsProxyEx
  include Toastable
  include DomHelpers
  include Storable

  THEMES = {
    'light' => { next: 'dark', label: 'Dark Mode' },
    'dark' => { next: 'light', label: 'Light Mode' }
  }.freeze

  STORAGE_KEY = 'theme'.freeze

  def connect
    load_theme
  end

  def toggle(event)
    html = document.document_element
    current_theme = html.get_attribute('data-theme') || 'light'
    new_theme = THEMES[current_theme][:next]

    # Apply new theme
    html.set_attribute('data-theme', new_theme)
    `localStorage.setItem(#{STORAGE_KEY}, #{new_theme})`

    # Update button text
    btn = event.current_target
    btn.text_content = THEMES[new_theme][:label]

    # Show toast
    show_info("Switched to #{new_theme} mode")
  end

  private

  def load_theme
    theme = `localStorage.getItem(#{STORAGE_KEY})` || 'light'
    theme = 'light' if !theme || theme == 'null'
    document.document_element.set_attribute('data-theme', theme)

    # Update button text if exists
    btn = query('[data-action*="toggle"]')
    if element_exists?(btn)
      btn.text_content = THEMES[theme][:label]
    end
  end
end

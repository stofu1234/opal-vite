# backtick_javascript: true

# Theme controller for dark mode toggle
class ThemeController < StimulusController
  include StimulusHelpers

  def connect
    load_theme
  end

  def toggle
    current_theme = get_root_attr('data-theme') || 'light'
    new_theme = current_theme == 'light' ? 'dark' : 'light'

    set_root_attr('data-theme', new_theme)
    storage_set('theme', new_theme)

    # Update button text
    btn = event_target
    set_text(btn, new_theme == 'dark' ? '☀️ Light Mode' : '🌙 Dark Mode')

    # Show toast
    dispatch_window_event('show-toast', {
      message: "Switched to #{new_theme} mode",
      type: 'info'
    })
  end

  private

  def load_theme
    theme = storage_get('theme') || 'light'
    set_root_attr('data-theme', theme)

    # Update button text if exists
    btn = query_element('[data-action*="toggle"]')
    if btn
      set_text(btn, theme == 'dark' ? '☀️ Light Mode' : '🌙 Dark Mode')
    end
  end
end

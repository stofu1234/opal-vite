# backtick_javascript: true

# Theme controller for dark mode toggle
class ThemeController < StimulusController
  def connect
    load_theme
  end

  def toggle
    `
      const html = document.documentElement;
      const currentTheme = html.getAttribute('data-theme') || 'light';
      const newTheme = currentTheme === 'light' ? 'dark' : 'light';

      html.setAttribute('data-theme', newTheme);
      localStorage.setItem('theme', newTheme);

      // Update button text
      const btn = event.currentTarget;
      btn.textContent = newTheme === 'dark' ? '☀️ Light Mode' : '🌙 Dark Mode';

      // Show toast
      const toastEvent = new CustomEvent('show-toast', {
        detail: {
          message: 'Switched to ' + newTheme + ' mode',
          type: 'info'
        }
      });
      window.dispatchEvent(toastEvent);
    `
  end

  private

  def load_theme
    `
      const theme = localStorage.getItem('theme') || 'light';
      document.documentElement.setAttribute('data-theme', theme);

      // Update button text if exists
      const btn = this.element.querySelector('[data-action*="toggle"]');
      if (btn) {
        btn.textContent = theme === 'dark' ? '☀️ Light Mode' : '🌙 Dark Mode';
      }
    `
  end
end

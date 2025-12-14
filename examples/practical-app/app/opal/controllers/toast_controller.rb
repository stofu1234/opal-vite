# backtick_javascript: true

# Toast notification controller
class ToastController < StimulusController
  self.targets = ["container"]

  def connect
    # Listen for show-toast event
    `
      window.addEventListener('show-toast', (e) => {
        this.show(e.detail.message, e.detail.type || 'info');
      });
    `
  end

  # Show toast notification
  def show
    `
      const message = arguments[0];
      const type = arguments[1] || 'info';

      // Find or create toast container
      let container = this.hasContainerTarget ? this.containerTarget : null;

      if (!container) {
        // Find the global toast container
        container = document.querySelector('.toast-container[data-toast-target="container"]');
      }

      if (!container) {
        console.warn('No toast container found');
        return;
      }

      const toast = document.createElement('div');
      toast.className = 'toast toast-' + type;

      // Add icon based on type
      let icon = 'ℹ️';
      if (type === 'success') icon = '✅';
      else if (type === 'error') icon = '❌';
      else if (type === 'warning') icon = '⚠️';

      toast.innerHTML = '<span class="toast-icon">' + icon + '</span>' +
                        '<span class="toast-message">' + message + '</span>';

      container.appendChild(toast);

      // Animate in
      setTimeout(() => toast.classList.add('show'), 10);

      // Auto remove after 3 seconds
      setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
      }, 3000);
    `
  end

  # Manually show toast (for testing)
  def show_test
    `
      const messages = [
        { text: 'Success message!', type: 'success' },
        { text: 'Error message!', type: 'error' },
        { text: 'Warning message!', type: 'warning' },
        { text: 'Info message!', type: 'info' }
      ];

      const random = messages[Math.floor(Math.random() * messages.length)];
      this.show(random.text, random.type);
    `
  end
end

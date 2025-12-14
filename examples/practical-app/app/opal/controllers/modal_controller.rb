# backtick_javascript: true

# Modal dialog controller with animations
class ModalController < StimulusController
  self.targets = ["overlay", "content", "title", "body", "input"]

  def connect
    puts "Modal controller connected!"

    # Listen for open-modal event
    `
      const ctrl = this;

      window.addEventListener('open-modal', (e) => {
        const data = e.detail;

        if (data.title && ctrl.hasTitleTarget) {
          ctrl.titleTarget.textContent = data.title;
        }

        if (data.todoText && ctrl.hasInputTarget) {
          ctrl.inputTarget.value = data.todoText;
          ctrl.inputTarget.setAttribute('data-todo-id', data.todoId);
        }

        // Open modal
        ctrl.element.classList.add('active');
        ctrl.overlayTarget.classList.add('active');
        ctrl.contentTarget.classList.add('active');

        // Focus input if exists
        if (ctrl.hasInputTarget) {
          setTimeout(() => ctrl.inputTarget.focus(), 100);
        }

        // Prevent body scroll
        document.body.style.overflow = 'hidden';
      });

      // Listen for update-todo event from modal
      this.element.addEventListener('modal-save', (e) => {
        const updateEvent = new CustomEvent('update-todo', {
          detail: e.detail
        });
        window.dispatchEvent(updateEvent);

        // Close modal
        ctrl.element.classList.remove('active');
        ctrl.overlayTarget.classList.remove('active');
        ctrl.contentTarget.classList.remove('active');
        document.body.style.overflow = '';

        // Reset form if exists
        if (ctrl.hasInputTarget) {
          ctrl.inputTarget.value = '';
          ctrl.inputTarget.removeAttribute('data-todo-id');
        }
      });
    `
  end

  # Open modal
  def open
    `
      this.element.classList.add('active');
      this.overlayTarget.classList.add('active');
      this.contentTarget.classList.add('active');

      // Focus input if exists
      if (this.hasInputTarget) {
        setTimeout(() => this.inputTarget.focus(), 100);
      }

      // Prevent body scroll
      document.body.style.overflow = 'hidden';
    `
  end

  # Open with data (for editing)
  def open_with_data
    # This method is called from JavaScript with data
    `
      const data = arguments[0];

      if (data.title && this.hasTitleTarget) {
        this.titleTarget.textContent = data.title;
      }

      if (data.todoText && this.hasInputTarget) {
        this.inputTarget.value = data.todoText;
        this.inputTarget.setAttribute('data-todo-id', data.todoId);
      }

      this.open();
    `
  end

  # Close modal
  def close
    `
      this.element.classList.remove('active');
      this.overlayTarget.classList.remove('active');
      this.contentTarget.classList.remove('active');

      // Restore body scroll
      document.body.style.overflow = '';

      // Reset form if exists
      if (this.hasInputTarget) {
        this.inputTarget.value = '';
        this.inputTarget.removeAttribute('data-todo-id');
      }
    `
  end

  # Close on overlay click
  def close_on_overlay
    `
      if (event.target === this.overlayTarget) {
        this.close();
      }
    `
  end

  # Close on Escape key
  def close_on_escape
    `
      if (event.key === 'Escape') {
        this.close();
      }
    `
  end

  # Save (for edit todo)
  def save
    `
      const input = this.inputTarget;
      const text = input.value.trim();

      if (text === '') {
        const event = new CustomEvent('show-toast', {
          detail: { message: 'Please enter todo text', type: 'error' }
        });
        window.dispatchEvent(event);
        return;
      }

      const todoId = input.getAttribute('data-todo-id');

      // Dispatch save event
      const saveEvent = new CustomEvent('modal-save', {
        detail: {
          todoId: parseInt(todoId),
          text: text
        }
      });
      this.element.dispatchEvent(saveEvent);
    `
  end
end

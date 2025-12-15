# backtick_javascript: true

# Modal dialog controller with animations
class ModalController < StimulusController
  self.targets = ["overlay", "content", "title", "body", "input"]

  def connect
    `
      const ctrl = this;

      // Stimulus action methods
      this.open = function() {
        ctrl.element.classList.add('active');
        ctrl.overlayTarget.classList.add('active');
        ctrl.contentTarget.classList.add('active');

        // Focus input if exists
        if (ctrl.hasInputTarget) {
          setTimeout(() => ctrl.inputTarget.focus(), 100);
        }

        // Prevent body scroll
        document.body.style.overflow = 'hidden';
      };

      this.close = function() {
        ctrl.element.classList.remove('active');
        ctrl.overlayTarget.classList.remove('active');
        ctrl.contentTarget.classList.remove('active');

        // Restore body scroll
        document.body.style.overflow = '';

        // Reset form if exists
        if (ctrl.hasInputTarget) {
          ctrl.inputTarget.value = '';
          ctrl.inputTarget.removeAttribute('data-todo-id');
        }
      };

      this.closeOnOverlay = function(event) {
        if (event.target === ctrl.overlayTarget) {
          this.close();
        }
      };

      this.closeOnEscape = function(event) {
        if (event.key === 'Escape') {
          this.close();
        }
      };

      this.save = function() {
        const input = ctrl.inputTarget;
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
        ctrl.element.dispatchEvent(saveEvent);
      };

      // Listen for open-modal event
      window.addEventListener('open-modal', function(e) {
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
      ctrl.element.addEventListener('modal-save', function(e) {
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
end

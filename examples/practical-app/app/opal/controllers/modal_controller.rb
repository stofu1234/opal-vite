# backtick_javascript: true

# Modal dialog controller with animations
class ModalController < StimulusController
  include JsProxyEx
  include Toastable
  include DomHelpers

  self.targets = ["overlay", "content", "title", "body", "input"]

  def connect
    setup_event_listeners
  end

  def open
    activate_modal
    focus_input_delayed
    prevent_body_scroll
  end

  def close
    deactivate_modal
    restore_body_scroll
    reset_input
  end

  def close_on_overlay(event)
    `
      if (this.hasOverlayTarget && event.target === this.overlayTarget) {
        this.$close();
      }
    `
  end

  def close_on_escape(event)
    close if event.key == 'Escape'
  end

  def save
    text = `this.hasInputTarget ? this.inputTarget.value.trim() : ''`

    if text.empty?
      show_error('Please enter todo text')
      return
    end

    todo_id = `this.hasInputTarget ? this.inputTarget.getAttribute('data-todo-id') : null`

    # Dispatch save event
    dispatch_custom_event('modal-save', { todoId: todo_id.to_i, text: text }, element)
  end

  private

  def setup_event_listeners
    # Listen for open-modal event
    `
      const ctrl = this;
      window.addEventListener('open-modal', function(e) {
        const data = e.detail;

        if (data.title && ctrl.hasTitleTarget) {
          ctrl.titleTarget.textContent = data.title;
        }

        if (data.todoText && ctrl.hasInputTarget) {
          ctrl.inputTarget.value = data.todoText;
          ctrl.inputTarget.setAttribute('data-todo-id', data.todoId);
        }

        ctrl.$open();
      });

      // Listen for modal-save event to dispatch update-todo
      ctrl.element.addEventListener('modal-save', function(e) {
        const updateEvent = new CustomEvent('update-todo', {
          detail: e.detail
        });
        window.dispatchEvent(updateEvent);
        ctrl.$close();
      });
    `
  end

  def activate_modal
    `
      this.element.classList.add('active');
      if (this.hasOverlayTarget) this.overlayTarget.classList.add('active');
      if (this.hasContentTarget) this.contentTarget.classList.add('active');
    `
  end

  def deactivate_modal
    `
      this.element.classList.remove('active');
      if (this.hasOverlayTarget) this.overlayTarget.classList.remove('active');
      if (this.hasContentTarget) this.contentTarget.classList.remove('active');
    `
  end

  def focus_input_delayed
    `
      const ctrl = this;
      if (this.hasInputTarget) {
        setTimeout(function() { ctrl.inputTarget.focus(); }, 100);
      }
    `
  end

  def prevent_body_scroll
    `document.body.style.overflow = 'hidden'`
  end

  def restore_body_scroll
    `document.body.style.overflow = ''`
  end

  def reset_input
    `
      if (this.hasInputTarget) {
        this.inputTarget.value = '';
        this.inputTarget.removeAttribute('data-todo-id');
      }
    `
  end
end

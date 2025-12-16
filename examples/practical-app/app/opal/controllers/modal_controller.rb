# backtick_javascript: true

# Modal dialog controller with animations
class ModalController < StimulusController
  include StimulusHelpers

  self.targets = ["overlay", "content", "title", "body", "input"]

  def connect
    # Listen for open-modal event
    on_window_event('open-modal') do |e|
      detail = `#{e}.detail`
      title = `#{detail}.title`
      todo_text = `#{detail}.todoText`
      todo_id = `#{detail}.todoId`

      target_set_text(:title, title) if has_target?(:title) && title

      if has_target?(:input) && todo_text
        target_set_value(:input, todo_text)
        input = get_target(:input)
        set_attr(input, 'data-todo-id', todo_id)
      end

      open_modal
    end

    # Listen for modal-save event on this element
    `
      const ctrl = this;
      this.element.addEventListener('modal-save', function(e) {
        const updateEvent = new CustomEvent('update-todo', { detail: e.detail });
        window.dispatchEvent(updateEvent);
        ctrl.$close_modal();
        if (ctrl['$has_target?']('input')) {
          ctrl.$reset_form();
        }
      });
    `
  end

  # Open modal
  def open
    open_modal
  end

  # Open with data (for editing)
  def open_with_data
    data = `arguments[0]`
    title = `#{data}.title`
    todo_text = `#{data}.todoText`
    todo_id = `#{data}.todoId`

    target_set_text(:title, title) if has_target?(:title) && title

    if has_target?(:input) && todo_text
      target_set_value(:input, todo_text)
      input = get_target(:input)
      set_attr(input, 'data-todo-id', todo_id)
    end

    open_modal
  end

  # Close modal
  def close
    close_modal
    reset_form if has_target?(:input)
  end

  # Close on overlay click
  def close_on_overlay
    target = event_target
    overlay = get_target(:overlay)
    close if `#{target} === #{overlay}`
  end

  # Close on Escape key
  def close_on_escape
    close if event_key == 'Escape'
  end

  # Save (for edit todo)
  def save
    input = get_target(:input)
    text = get_value(input)
    text = `#{text}.trim()`

    if `#{text} === ''`
      dispatch_window_event('show-toast', {
        message: 'Please enter todo text',
        type: 'error'
      })
      return
    end

    todo_id = get_attr(input, 'data-todo-id')

    # Dispatch save event
    dispatch_event('modal-save', {
      todoId: parse_int(todo_id),
      text: text
    })
  end

  private

  def open_modal
    element_add_class('active')
    add_target_class(:overlay, 'active')
    add_target_class(:content, 'active')

    if has_target?(:input)
      set_timeout(100) { target_focus(:input) }
    end

    lock_body_scroll
  end

  def close_modal
    element_remove_class('active')
    remove_target_class(:overlay, 'active')
    remove_target_class(:content, 'active')
    unlock_body_scroll
  end

  def reset_form
    target_set_value(:input, '')
    input = get_target(:input)
    remove_attr(input, 'data-todo-id')
  end
end

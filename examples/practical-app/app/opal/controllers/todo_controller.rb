# backtick_javascript: true

# TodoController - UI coordination for todo management
#
# This controller is responsible for:
# - Handling user actions (add, toggle, delete, edit, filter)
# - Coordinating between storage service and presenter
# - Managing toast notifications
#
# Storage operations are in TodoStorageService
# DOM rendering is in TodoPresenter
#
class TodoController < StimulusController
  include StimulusHelpers

  self.targets = ["list", "input", "template", "count", "emptyState"]
  self.values = { storage_key: :string, filter: :string }

  def initialize
    super
    @storage_key_value = "opal_todos"
    @filter_value = "all"
  end

  def connect
    @storage = TodoStorageService.new(@storage_key_value)
    @presenter = TodoPresenter.new(self)

    # Listen for update-todo event from modal
    on_window_event('update-todo') do |e|
      detail = `#{e}.detail`
      todo_id = parse_int(`#{detail}.todoId`)
      new_text = `#{detail}.text`
      handle_update_todo(todo_id, new_text)
    end

    render_todos
  end

  # Action: Add new todo
  def add_todo
    text = target_value(:input)
    text = `#{text}.trim()`

    if `#{text} === ''`
      show_toast('Please enter a todo item', 'error')
      return
    end

    @storage.add(text)
    target_set_value(:input, '')
    render_todos
    show_toast('Todo added!', 'success')
  end

  # Action: Toggle todo completion
  def toggle_todo
    todo_id = event_data_int('todo-id')
    if @storage.toggle(todo_id)
      render_todos
    end
  end

  # Action: Delete todo
  def delete_todo
    todo_id = event_data_int('todo-id')
    @storage.delete(todo_id)
    render_todos
    show_toast('Todo deleted', 'info')
  end

  # Action: Edit todo (show modal)
  def edit_todo
    todo_id = event_data_int('todo-id')
    todo = @storage.find(todo_id)

    if todo
      dispatch_window_event('open-modal', {
        title: 'Edit Todo',
        todoId: todo_id,
        todoText: `#{todo}.text`
      })
    end
  end

  # Action: Clear completed todos
  def clear_completed
    cleared_count = @storage.clear_completed

    if cleared_count == 0
      show_toast('No completed todos to clear', 'info')
      return
    end

    render_todos
    show_toast('Completed todos cleared', 'success')
  end

  # Action: Set filter and update display
  def set_filter
    filter = event_data('filter')
    `this.filterValue = #{filter}`

    # Update active button
    filter_buttons = query_all_element('[data-filter]')
    filter_buttons.each { |btn| remove_class(btn, 'active') }
    add_class(event_target, 'active')

    render_todos
  end

  private

  def handle_update_todo(todo_id, new_text)
    if @storage.update_text(todo_id, new_text)
      @presenter.update_todo_text(todo_id, new_text)
      show_toast('Todo updated!', 'success')
    end
  end

  def render_todos
    filter = `this.filterValue || 'all'`
    todos = @storage.filter(`#{filter}`)
    @presenter.render_all(todos)
    @presenter.update_count(@storage.counts)
  end

  def show_toast(message, type)
    dispatch_window_event('show-toast', {
      message: message,
      type: type
    })
  end
end

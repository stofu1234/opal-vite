# backtick_javascript: true

# Main Todo controller with CRUD operations and LocalStorage persistence
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
    # Listen for update-todo event from modal
    on_window_event('update-todo') do |e|
      detail = `#{e}.detail`
      todo_id = parse_int(`#{detail}.todoId`)
      new_text = `#{detail}.text`

      update_todo_text(todo_id, new_text)
    end

    load_todos
    update_count
  end

  # Add new todo
  def add_todo
    text = target_value(:input)
    text = `#{text}.trim()`

    if `#{text} === ''`
      dispatch_window_event('show-toast', {
        message: 'Please enter a todo item',
        type: 'error'
      })
      return
    end

    todo = {
      id: js_timestamp,
      text: text,
      completed: false,
      createdAt: js_iso_date
    }

    todos = get_todos
    `#{todos}.push(#{todo.to_n})`
    save_todos(todos)

    target_set_value(:input, '')
    render_todos

    dispatch_window_event('show-toast', {
      message: 'Todo added!',
      type: 'success'
    })
  end

  # Toggle todo completion
  def toggle_todo
    todo_id = event_data_int('todo-id')
    todos = get_todos
    todo = `#{todos}.find(function(t) { return t.id === #{todo_id} })`

    if todo
      `#{todo}.completed = !#{todo}.completed`
      save_todos(todos)
      render_todos
    end
  end

  # Delete todo
  def delete_todo
    todo_id = event_data_int('todo-id')
    todos = get_todos
    filtered = `#{todos}.filter(function(t) { return t.id !== #{todo_id} })`

    save_todos(filtered)
    render_todos

    dispatch_window_event('show-toast', {
      message: 'Todo deleted',
      type: 'info'
    })
  end

  # Edit todo (show modal)
  def edit_todo
    todo_id = event_data_int('todo-id')
    todos = get_todos
    todo = `#{todos}.find(function(t) { return t.id === #{todo_id} })`

    if todo
      dispatch_window_event('open-modal', {
        title: 'Edit Todo',
        todoId: todo_id,
        todoText: `#{todo}.text`
      })
    end
  end

  # Clear completed todos
  def clear_completed
    todos = get_todos
    completed_count = `#{todos}.filter(function(t) { return t.completed }).length`

    if `#{completed_count} === 0`
      dispatch_window_event('show-toast', {
        message: 'No completed todos to clear',
        type: 'info'
      })
      return
    end

    active_todos = `#{todos}.filter(function(t) { return !t.completed })`
    save_todos(active_todos)
    render_todos

    dispatch_window_event('show-toast', {
      message: 'Completed todos cleared',
      type: 'success'
    })
  end

  # Set filter and update display
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

  def get_todos
    storage_get_json(@storage_key_value, `[]`)
  end

  def save_todos(todos)
    `localStorage.setItem(#{@storage_key_value}, JSON.stringify(#{todos}))`
  end

  def update_todo_text(todo_id, new_text)
    todos = get_todos
    todo = `#{todos}.find(function(t) { return t.id === #{todo_id} })`

    if todo
      `#{todo}.text = #{new_text}`
      save_todos(todos)

      # Update DOM
      todo_el = query("[data-todo-id=\"#{todo_id}\"]")
      if todo_el
        text_el = `#{todo_el}.querySelector('.todo-text')`
        set_text(text_el, new_text) if text_el
      end

      dispatch_window_event('show-toast', {
        message: 'Todo updated!',
        type: 'success'
      })
    end
  end

  def add_todo_to_dom(todo)
    clone = clone_template(:template)
    todo_item = template_first_child(clone)

    return unless todo_item

    set_attr(todo_item, 'data-todo-id', `#{todo}.id`)
    add_class(todo_item, 'completed') if `#{todo}.completed`

    checkbox = `#{todo_item}.querySelector('.todo-checkbox')`
    if checkbox
      set_attr(checkbox, 'data-todo-id', `#{todo}.id`)
      `#{checkbox}.checked = #{todo}.completed`
    end

    text_el = `#{todo_item}.querySelector('.todo-text')`
    set_text(text_el, `#{todo}.text`) if text_el

    edit_btn = `#{todo_item}.querySelector('.edit-btn')`
    set_attr(edit_btn, 'data-todo-id', `#{todo}.id`) if edit_btn

    delete_btn = `#{todo_item}.querySelector('.delete-btn')`
    set_attr(delete_btn, 'data-todo-id', `#{todo}.id`) if delete_btn

    list = get_target(:list)
    append_child(list, clone)
    hide_empty_state
  end

  def render_todos
    list = get_target(:list)
    set_html(list, '')

    todos = get_todos
    filter = `this.filterValue || 'all'`

    # Filter todos
    filtered_todos = case `#{filter}`
                     when 'active'
                       `#{todos}.filter(function(t) { return !t.completed })`
                     when 'completed'
                       `#{todos}.filter(function(t) { return t.completed })`
                     else
                       todos
                     end

    # Render each todo
    length = `#{filtered_todos}.length`
    `for (var i = 0; i < #{length}; i++) {`
      todo = `#{filtered_todos}[i]`
      add_todo_to_dom(todo)
    `}`

    if `#{length} === 0`
      show_empty_state
    else
      hide_empty_state
    end

    update_count
  end

  def update_count
    todos = get_todos
    active = `#{todos}.filter(function(t) { return !t.completed }).length`
    completed = `#{todos}.filter(function(t) { return t.completed }).length`

    target_set_html(:count, "#{active} active, #{completed} completed") if has_target?(:count)

    show_empty_state if `#{todos}.length === 0`
  end

  def show_empty_state
    show_target(:emptyState) if has_target?(:emptyState)
  end

  def hide_empty_state
    hide_target(:emptyState) if has_target?(:emptyState)
  end

  def load_todos
    render_todos
  end
end

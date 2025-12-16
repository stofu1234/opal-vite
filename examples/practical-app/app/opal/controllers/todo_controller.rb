# backtick_javascript: true

# Main Todo controller with CRUD operations and LocalStorage persistence
# Uses StimulusHelpers DSL macros to reduce JavaScript backticks
class TodoController < StimulusController
  include JsProxyEx
  include Toastable
  include DomHelpers
  include Storable
  include StimulusHelpers

  self.targets = ["list", "input", "template", "count", "emptyState"]
  self.values = { storage_key: :string, filter: :string }

  STORAGE_KEY = 'opal_todos'

  def initialize
    super
    @filter = 'all'
  end

  def connect
    setup_update_listener
    render_todos
  end

  # Add new todo - uses DSL helpers for target access
  def add_todo
    text = target_value(:input)&.strip || ''

    if text.empty?
      show_error('Please enter a todo item')
      return
    end

    todo = {
      id: generate_id,          # DSL helper instead of `Date.now()`
      text: text,
      completed: false,
      createdAt: js_iso_date    # DSL helper instead of `new Date().toISOString()`
    }

    todos = get_todos
    todos << todo
    save_todos(todos)

    target_clear(:input)        # DSL helper instead of backtick
    render_todos
    show_success('Todo added!')
  end

  # Toggle todo completion
  def toggle_todo(event)
    todo_id = event.current_target.get_attribute('data-todo-id').to_i

    todos = get_todos
    todo = todos.find { |t| t[:id] == todo_id }

    if todo
      todo[:completed] = !todo[:completed]
      save_todos(todos)
      render_todos
    end
  end

  # Delete todo
  def delete_todo(event)
    todo_id = event.current_target.get_attribute('data-todo-id').to_i

    todos = get_todos.reject { |t| t[:id] == todo_id }
    save_todos(todos)
    render_todos
    show_info('Todo deleted')
  end

  # Edit todo (show modal)
  def edit_todo(event)
    todo_id = event.current_target.get_attribute('data-todo-id').to_i
    todos = get_todos
    todo = todos.find { |t| t[:id] == todo_id }

    if todo
      dispatch_custom_event('open-modal', {
        title: 'Edit Todo',
        todoId: todo_id,
        todoText: todo[:text]
      })
    end
  end

  # Clear completed todos
  def clear_completed
    todos = get_todos
    completed_count = todos.count { |t| t[:completed] }

    if completed_count == 0
      show_info('No completed todos to clear')
      return
    end

    active_todos = todos.reject { |t| t[:completed] }
    save_todos(active_todos)
    render_todos
    show_success('Completed todos cleared')
  end

  # Set filter and update display
  def set_filter(event)
    @filter = event.current_target.get_attribute('data-filter')

    # Update active button
    filter_buttons = query_all('[data-filter]')
    filter_buttons.each { |btn| remove_class(btn, 'active') }
    add_class(event.current_target, 'active')

    render_todos
  end

  private

  def setup_update_listener
    `
      const ctrl = this;
      window.addEventListener('update-todo', function(e) {
        const todoId = parseInt(e.detail.todoId);
        const newText = e.detail.text;
        ctrl.$handle_update_todo(todoId, newText);
      });
    `
  end

  def handle_update_todo(todo_id, new_text)
    todos = get_todos
    todo = todos.find { |t| t[:id] == todo_id }

    if todo
      todo[:text] = new_text
      save_todos(todos)

      # Update DOM
      todo_el = document.query_selector("[data-todo-id=\"#{todo_id}\"]")
      if element_exists?(todo_el)
        text_el = todo_el.query_selector('.todo-text')
        text_el.text_content = new_text if element_exists?(text_el)
      end

      show_success('Todo updated!')
    end
  end

  def get_todos
    js_data = storage_get(STORAGE_KEY)
    return [] unless js_data

    # Convert JS array to Ruby array of hashes
    result = []
    length = `#{js_data}.length`
    length.times do |i|
      item = `#{js_data}[#{i}]`
      result << {
        id: `#{item}.id`,
        text: `#{item}.text`,
        completed: `#{item}.completed`,
        createdAt: `#{item}.createdAt`
      }
    end
    result
  end

  def save_todos(todos)
    # Convert Ruby array to JS array for storage
    js_array = `[]`
    todos.each do |todo|
      `#{js_array}.push({
        id: #{todo[:id]},
        text: #{todo[:text]},
        completed: #{todo[:completed]},
        createdAt: #{todo[:createdAt]}
      })`
    end
    storage_set(STORAGE_KEY, `#{js_array}`)
  end

  def render_todos
    target_clear_html(:list)    # DSL helper

    todos = get_todos
    filtered_todos = filter_todos(todos)

    filtered_todos.each { |todo| add_todo_to_dom(todo) }

    if filtered_todos.empty?
      show_empty_state
    else
      hide_empty_state
    end

    update_count
  end

  def filter_todos(todos)
    case @filter
    when 'active'
      todos.reject { |t| t[:completed] }
    when 'completed'
      todos.select { |t| t[:completed] }
    else
      todos
    end
  end

  def add_todo_to_dom(todo)
    return unless has_target?(:template) && has_target?(:list)  # DSL helpers

    todo_id = todo[:id]
    todo_text = todo[:text]
    todo_completed = todo[:completed]

    `
      const template = this.templateTarget;
      const clone = template.content.cloneNode(true);
      const todoItem = clone.firstElementChild;

      if (!todoItem) return;

      todoItem.setAttribute('data-todo-id', #{todo_id});
      if (#{todo_completed}) {
        todoItem.classList.add('completed');
      }

      // Set checkbox
      const checkbox = todoItem.querySelector('.todo-checkbox');
      if (checkbox) {
        checkbox.setAttribute('data-todo-id', #{todo_id});
        checkbox.checked = #{todo_completed};
      }

      // Set text
      const textEl = todoItem.querySelector('.todo-text');
      if (textEl) {
        textEl.textContent = #{todo_text};
      }

      // Set edit button
      const editBtn = todoItem.querySelector('.edit-btn');
      if (editBtn) {
        editBtn.setAttribute('data-todo-id', #{todo_id});
      }

      // Set delete button
      const deleteBtn = todoItem.querySelector('.delete-btn');
      if (deleteBtn) {
        deleteBtn.setAttribute('data-todo-id', #{todo_id});
      }

      this.listTarget.appendChild(clone);
    `
    hide_empty_state
  end

  def update_count
    todos = get_todos
    active = todos.count { |t| !t[:completed] }
    completed = todos.count { |t| t[:completed] }

    count_text = "#{active} active, #{completed} completed"
    target_set_html(:count, count_text)  # DSL helper

    show_empty_state if todos.empty?
  end

  def show_empty_state
    set_target_style(:empty_state, 'display', 'block')
  end

  def hide_empty_state
    hide_target(:empty_state)
  end
end

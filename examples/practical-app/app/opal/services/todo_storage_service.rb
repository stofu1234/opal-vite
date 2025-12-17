# backtick_javascript: true

# TodoStorageService - LocalStorage persistence for todos
#
# This service handles:
# - Reading/writing todos to localStorage
# - CRUD operations on todo data
# - Filtering todos by status
#
# Usage:
#   service = TodoStorageService.new('my_todos')
#   todos = service.all
#   service.add(text: 'New todo')
#   service.toggle(todo_id)
#   service.delete(todo_id)
#
class TodoStorageService
  include StimulusHelpers

  attr_reader :storage_key

  def initialize(storage_key = 'opal_todos')
    @storage_key = storage_key
  end

  # Get all todos from storage
  #
  # @return [Native] JavaScript array of todos
  def all
    storage_get_json(@storage_key, `[]`)
  end

  # Save todos to storage
  #
  # @param todos [Native] JavaScript array of todos
  def save(todos)
    `localStorage.setItem(#{@storage_key}, JSON.stringify(#{todos}))`
  end

  # Add a new todo
  #
  # @param text [String] Todo text
  # @return [Native] The created todo object
  def add(text)
    todo = {
      id: js_timestamp,
      text: text,
      completed: false,
      createdAt: js_iso_date
    }

    todos = all
    `#{todos}.push(#{todo.to_n})`
    save(todos)
    todo.to_n
  end

  # Find a todo by ID
  #
  # @param todo_id [Integer] Todo ID
  # @return [Native, nil] The todo object or nil
  def find(todo_id)
    todos = all
    `#{todos}.find(function(t) { return t.id === #{todo_id} })`
  end

  # Toggle todo completion status
  #
  # @param todo_id [Integer] Todo ID
  # @return [Boolean] Whether toggle was successful
  def toggle(todo_id)
    todos = all
    todo = `#{todos}.find(function(t) { return t.id === #{todo_id} })`

    if todo
      `#{todo}.completed = !#{todo}.completed`
      save(todos)
      true
    else
      false
    end
  end

  # Update todo text
  #
  # @param todo_id [Integer] Todo ID
  # @param new_text [String] New text
  # @return [Boolean] Whether update was successful
  def update_text(todo_id, new_text)
    todos = all
    todo = `#{todos}.find(function(t) { return t.id === #{todo_id} })`

    if todo
      `#{todo}.text = #{new_text}`
      save(todos)
      true
    else
      false
    end
  end

  # Delete a todo by ID
  #
  # @param todo_id [Integer] Todo ID
  def delete(todo_id)
    todos = all
    filtered = `#{todos}.filter(function(t) { return t.id !== #{todo_id} })`
    save(filtered)
  end

  # Clear all completed todos
  #
  # @return [Integer] Number of cleared todos
  def clear_completed
    todos = all
    completed_count = `#{todos}.filter(function(t) { return t.completed }).length`
    active_todos = `#{todos}.filter(function(t) { return !t.completed })`
    save(active_todos)
    `#{completed_count}`
  end

  # Filter todos by status
  #
  # @param filter [String] 'all', 'active', or 'completed'
  # @return [Native] Filtered JavaScript array
  def filter(filter_type)
    todos = all

    case filter_type
    when 'active'
      `#{todos}.filter(function(t) { return !t.completed })`
    when 'completed'
      `#{todos}.filter(function(t) { return t.completed })`
    else
      todos
    end
  end

  # Count statistics
  #
  # @return [Hash] Hash with :total, :active, :completed counts
  def counts
    todos = all
    total = `#{todos}.length`
    active = `#{todos}.filter(function(t) { return !t.completed }).length`
    completed = `#{todos}.filter(function(t) { return t.completed }).length`

    { total: total, active: active, completed: completed }
  end
end

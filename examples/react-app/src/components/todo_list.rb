require 'react'

class TodoList
  include React::Component

  define_state :todos, []
  define_state :input, ''

  def render
    div class_name: 'todo-container' do
      div class_name: 'todo-card' do
        h2 'Todo List Component'

        div class_name: 'todo-input-group' do
          input(
            type: 'text',
            value: state.input,
            on_change: method(:handle_input_change),
            on_key_press: method(:handle_key_press),
            placeholder: 'Add a new todo...',
            class_name: 'todo-input'
          )
          button(
            on_click: method(:add_todo),
            class_name: 'btn btn-add'
          ) { span '+ Add' }
        end

        if state.todos.empty?
          div class_name: 'empty-state' do
            p '📝 No todos yet. Add one above!'
          end
        else
          ul class_name: 'todo-list' do
            state.todos.each_with_index do |todo, index|
              li key: index, class_name: "todo-item #{todo[:completed] ? 'completed' : ''}" do
                input(
                  type: 'checkbox',
                  checked: todo[:completed],
                  on_change: -> { toggle_todo(index) },
                  class_name: 'todo-checkbox'
                )
                span(
                  class_name: 'todo-text',
                  on_click: -> { toggle_todo(index) }
                ) { todo[:text] }
                button(
                  on_click: -> { remove_todo(index) },
                  class_name: 'btn-remove'
                ) { span '×' }
              end
            end
          end

          div class_name: 'todo-stats' do
            p "Total: #{state.todos.length} | " \
              "Completed: #{state.todos.count { |t| t[:completed] }} | " \
              "Active: #{state.todos.count { |t| !t[:completed] }}"
          end
        end
      end
    end
  end

  def handle_input_change(event)
    set_state(input: event.target.value)
  end

  def handle_key_press(event)
    add_todo(event) if event.key == 'Enter'
  end

  def add_todo(_event)
    return if state.input.strip.empty?

    new_todo = { text: state.input, completed: false }
    set_state(
      todos: state.todos + [new_todo],
      input: ''
    )
  end

  def toggle_todo(index)
    new_todos = state.todos.map.with_index do |todo, i|
      if i == index
        todo.merge(completed: !todo[:completed])
      else
        todo
      end
    end
    set_state(todos: new_todos)
  end

  def remove_todo(index)
    new_todos = state.todos.select.with_index { |_, i| i != index }
    set_state(todos: new_todos)
  end
end

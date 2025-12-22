# backtick_javascript: true

# Todo App Component using Snabberb
#
# Demonstrates:
# - Complex state management with arrays
# - Input handling
# - List rendering with v-for style iteration
# - Conditional rendering
#
class TodoApp < Snabberb::Component
  needs :todos, default: [], store: true
  needs :new_todo, default: '', store: true
  needs :next_id, default: 1, store: true

  def render
    h(:div, [
      # Input form
      h(:div, { class: { 'todo-input': true } }, [
        h(:input, {
          attrs: {
            type: 'text',
            placeholder: 'What needs to be done?'
          },
          props: { value: @new_todo },
          on: {
            input: ->(e) { store(:new_todo, `e.target.value`) },
            keyup: ->(e) { add_todo if `e.key === 'Enter'` }
          }
        }),
        h(:button, {
          on: { click: -> { add_todo } }
        }, 'Add')
      ]),

      # Todo list or empty state
      if @todos.empty?
        h(:div, { class: { 'empty-state': true } }, [
          h(:p, 'No todos yet. Add one above!')
        ])
      else
        h(:ul, { class: { 'todo-list': true } },
          @todos.map { |todo| render_todo_item(todo) })
      end,

      # Stats
      if @todos.any?
        h(:div, { class: { 'todo-stats': true } }, [
          h(:span, "#{remaining_count} item#{remaining_count == 1 ? '' : 's'} left"),
          if completed_count > 0
            h(:button, {
              class: { 'clear-completed': true },
              on: { click: -> { clear_completed } }
            }, "Clear completed (#{completed_count})")
          end
        ].compact)
      end
    ].compact)
  end

  private

  def render_todo_item(todo)
    h(:li, {
      key: todo[:id],
      class: { 'todo-item': true, completed: todo[:completed] }
    }, [
      h(:input, {
        attrs: { type: 'checkbox' },
        props: { checked: todo[:completed] },
        on: { change: -> { toggle_todo(todo[:id]) } }
      }),
      h(:span, todo[:text]),
      h(:button, {
        class: { 'delete-btn': true },
        on: { click: -> { remove_todo(todo[:id]) } }
      }, 'Delete')
    ])
  end

  def add_todo
    text = @new_todo.strip
    return if text.empty?

    new_todos = @todos + [{ id: @next_id, text: text, completed: false }]
    store(:todos, new_todos)
    store(:next_id, @next_id + 1)
    store(:new_todo, '')
  end

  def remove_todo(id)
    new_todos = @todos.reject { |t| t[:id] == id }
    store(:todos, new_todos)
  end

  def toggle_todo(id)
    new_todos = @todos.map do |t|
      if t[:id] == id
        { id: t[:id], text: t[:text], completed: !t[:completed] }
      else
        t
      end
    end
    store(:todos, new_todos)
  end

  def clear_completed
    new_todos = @todos.reject { |t| t[:completed] }
    store(:todos, new_todos)
  end

  def remaining_count
    @todos.count { |t| !t[:completed] }
  end

  def completed_count
    @todos.count { |t| t[:completed] }
  end
end

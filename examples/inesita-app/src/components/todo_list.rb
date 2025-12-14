class TodoList
  include Inesita::Component

  def render
    div class: 'todo-container' do
      div class: 'nav-header' do
        a href: '/', onclick: router.method(:go_to) do
          text '← Back to Home'
        end
      end

      div class: 'todo-card' do
        h2 { text 'Todo List' }

        div class: 'todo-input-group' do
          input(
            type: 'text',
            class: 'todo-input',
            placeholder: 'Add a new todo...',
            value: input_value,
            oninput: method(:handle_input),
            onkeypress: method(:handle_keypress)
          )
          button class: 'btn btn-add', onclick: method(:add_todo) do
            text '+ Add'
          end
        end

        if store.todos.empty?
          div class: 'empty-state' do
            p { text '📝 No todos yet. Add one above!' }
          end
        else
          ul class: 'todo-list' do
            store.todos.each do |todo|
              li class: "todo-item #{todo[:completed] ? 'completed' : ''}" do
                input(
                  type: 'checkbox',
                  class: 'todo-checkbox',
                  checked: todo[:completed],
                  onchange: -> { toggle_todo(todo[:id]) }
                )
                span class: 'todo-text', onclick: -> { toggle_todo(todo[:id]) } do
                  text todo[:text]
                end
                button class: 'btn-remove', onclick: -> { remove_todo(todo[:id]) } do
                  text '×'
                end
              end
            end
          end

          div class: 'todo-stats' do
            p do
              text "Total: #{store.todos.length} | "
              text "Completed: #{store.completed_count} | "
              text "Active: #{store.active_count}"
            end
          end
        end
      end
    end
  end

  private

  def input_value
    @input_value ||= ''
  end

  def handle_input(event)
    @input_value = `event.target.value`
  end

  def handle_keypress(event)
    add_todo if `event.key` == 'Enter'
  end

  def add_todo
    if input_value && !input_value.strip.empty?
      store.add_todo(input_value)
      @input_value = ''
      render!
    end
  end

  def toggle_todo(id)
    store.toggle_todo(id)
    render!
  end

  def remove_todo(id)
    store.remove_todo(id)
    render!
  end
end

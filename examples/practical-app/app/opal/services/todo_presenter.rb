# backtick_javascript: true

# TodoPresenter - DOM rendering for todos
#
# This presenter handles:
# - Rendering todo items from template
# - Managing empty state visibility
# - Updating count display
#
# Usage:
#   presenter = TodoPresenter.new(controller)
#   presenter.render_all(todos)
#   presenter.update_count(active: 3, completed: 2)
#
class TodoPresenter
  include StimulusHelpers

  def initialize(controller)
    @controller = controller
  end

  # Render all todos to the list
  #
  # @param todos [Native] JavaScript array of todos
  def render_all(todos)
    list = @controller.get_target(:list)
    set_html(list, '')

    length = `#{todos}.length`
    `for (var i = 0; i < #{length}; i++) {`
      todo = `#{todos}[i]`
      render_todo_item(todo, list)
    `}`

    if `#{length} === 0`
      show_empty_state
    else
      hide_empty_state
    end
  end

  # Render a single todo item and append to list
  #
  # @param todo [Native] JavaScript todo object
  # @param list [Native] DOM element to append to
  def render_todo_item(todo, list)
    clone = @controller.clone_template(:template)
    todo_item = template_first_child(clone)

    return unless todo_item

    setup_todo_element(todo_item, todo)
    append_child(list, clone)
  end

  # Update the text of a specific todo in the DOM
  #
  # @param todo_id [Integer] Todo ID
  # @param new_text [String] New text to display
  def update_todo_text(todo_id, new_text)
    todo_el = query("[data-todo-id=\"#{todo_id}\"]")
    if todo_el
      text_el = `#{todo_el}.querySelector('.todo-text')`
      set_text(text_el, new_text) if text_el
    end
  end

  # Update count display
  #
  # @param counts [Hash] Hash with :active and :completed counts
  def update_count(counts)
    if @controller.has_target?(:count)
      @controller.target_set_html(:count, "#{counts[:active]} active, #{counts[:completed]} completed")
    end

    show_empty_state if counts[:total] == 0
  end

  # Show empty state message
  def show_empty_state
    @controller.show_target(:emptyState) if @controller.has_target?(:emptyState)
  end

  # Hide empty state message
  def hide_empty_state
    @controller.hide_target(:emptyState) if @controller.has_target?(:emptyState)
  end

  private

  def setup_todo_element(element, todo)
    set_attr(element, 'data-todo-id', `#{todo}.id`)
    add_class(element, 'completed') if `#{todo}.completed`

    setup_checkbox(element, todo)
    setup_text(element, todo)
    setup_buttons(element, todo)
  end

  def setup_checkbox(element, todo)
    checkbox = `#{element}.querySelector('.todo-checkbox')`
    if checkbox
      set_attr(checkbox, 'data-todo-id', `#{todo}.id`)
      `#{checkbox}.checked = #{todo}.completed`
    end
  end

  def setup_text(element, todo)
    text_el = `#{element}.querySelector('.todo-text')`
    set_text(text_el, `#{todo}.text`) if text_el
  end

  def setup_buttons(element, todo)
    edit_btn = `#{element}.querySelector('.edit-btn')`
    set_attr(edit_btn, 'data-todo-id', `#{todo}.id`) if edit_btn

    delete_btn = `#{element}.querySelector('.delete-btn')`
    set_attr(delete_btn, 'data-todo-id', `#{todo}.id`) if delete_btn
  end
end

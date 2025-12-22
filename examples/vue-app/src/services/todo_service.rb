# TodoService - Pure Ruby business logic for todos (解決策①)
#
# This class contains all todo business logic without any JavaScript dependency.
# It handles storage persistence and can be tested with pure Ruby specs.
#
class TodoService
  STORAGE_KEY = 'opal-vue-todos'

  attr_reader :todos, :next_id

  def initialize
    @todos = []
    @next_id = 1
    load_from_storage
  end

  def add(text)
    text = text.strip
    return nil if text.empty?

    todo = { id: @next_id, text: text, completed: false }
    @next_id += 1
    @todos << todo
    save_to_storage
    todo
  end

  def remove(id)
    index = @todos.index { |t| t[:id] == id }
    return nil unless index

    removed = @todos.delete_at(index)
    save_to_storage
    removed
  end

  def toggle(id)
    todo = find(id)
    return nil unless todo

    todo[:completed] = !todo[:completed]
    save_to_storage
    todo
  end

  def clear_completed
    @todos.reject! { |t| t[:completed] }
    save_to_storage
  end

  def find(id)
    @todos.find { |t| t[:id] == id }
  end

  # Computed values
  def remaining
    @todos.count { |t| !t[:completed] }
  end

  def completed_count
    @todos.count { |t| t[:completed] }
  end

  def all_completed?
    @todos.all? { |t| t[:completed] }
  end

  private

  def load_from_storage
    saved = `localStorage.getItem(#{STORAGE_KEY})`
    return unless saved && `#{saved} !== null`

    parsed = `JSON.parse(#{saved})`
    # Convert JS array to Ruby array of hashes
    length = `#{parsed}.length`
    `for (var i = 0; i < #{length}; i++) {`
      item = `#{parsed}[i]`
      @todos << {
        id: `#{item}.id`,
        text: `#{item}.text`,
        completed: `#{item}.completed`
      }
    `}`

    # Set next_id to max id + 1
    if @todos.any?
      max_id = @todos.map { |t| t[:id] }.max
      @next_id = max_id + 1
    end
  end

  def save_to_storage
    json = `JSON.stringify(#{@todos.map(&:to_n)})`
    `localStorage.setItem(#{STORAGE_KEY}, #{json})`
  end

  # Convert todos to native JS array for Vue
  def to_native
    @todos.map(&:to_n)
  end
end

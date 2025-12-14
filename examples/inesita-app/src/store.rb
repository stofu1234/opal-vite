class Store
  include Inesita::Injection

  attr_accessor :counter, :todos

  def init
    @counter = 0
    @todos = []
  end

  def increase_counter
    @counter += 1
  end

  def decrease_counter
    @counter -= 1
  end

  def reset_counter
    @counter = 0
  end

  def add_todo(text)
    @todos << { text: text, completed: false, id: Time.now.to_f }
  end

  def toggle_todo(id)
    todo = @todos.find { |t| t[:id] == id }
    todo[:completed] = !todo[:completed] if todo
  end

  def remove_todo(id)
    @todos.reject! { |t| t[:id] == id }
  end

  def completed_count
    @todos.count { |t| t[:completed] }
  end

  def active_count
    @todos.count { |t| !t[:completed] }
  end
end

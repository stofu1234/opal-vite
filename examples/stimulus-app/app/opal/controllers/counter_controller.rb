# Counter controller demonstrating Stimulus Values API
class CounterController < StimulusController
  self.values = { count: :number }
  self.targets = ["display"]

  def initialize
    super
    @count_value = 0
  end

  def connect
    update_display
  end

  def increment
    self.count_value += 1
    update_display
  end

  def decrement
    self.count_value -= 1
    update_display
  end

  def reset
    self.count_value = 0
    update_display
  end

  private

  def update_display
    display_target.text_content = count_value.to_s
  end

  def count_value_changed
    puts "Count changed to: #{count_value}"
  end
end

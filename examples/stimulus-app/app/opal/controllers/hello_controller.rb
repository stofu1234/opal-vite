# backtick_javascript: true

# Simple Hello World controller demonstrating basic Stimulus features
class HelloController < StimulusController
  include StimulusHelpers

  self.targets = ["name", "output"]

  def connect
    puts "Hello controller connected!"
  end

  def greet
    name = target_value(:name)
    target_set_text(:output, "Hello, #{name}! (from Ruby)")
  end
end

# Simple Hello World controller demonstrating basic Stimulus features
class HelloController < StimulusController
  self.targets = ["name", "output"]

  def connect
    puts "Hello controller connected!"
  end

  def greet
    name = name_target.value
    output_target.text_content = "Hello, #{name}! (from Ruby)"
  end
end

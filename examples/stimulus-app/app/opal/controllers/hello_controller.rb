# backtick_javascript: true

# Simple Hello World controller demonstrating basic Stimulus features
class HelloController < StimulusController
  include JsProxyEx

  self.targets = ["name", "output"]

  def connect
    puts "Hello controller connected!"
  end

  def greet
    name = `this.nameTarget.value`
    `this.outputTarget.textContent = #{"Hello, #{name}! (from Ruby)"}`
  end
end

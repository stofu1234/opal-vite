# backtick_javascript: true
# Welcome to Opal + Vite!
# This Ruby code will be compiled to JavaScript and run in the browser.

puts "🚀 Ruby code is running in the browser!"
puts "Opal version: #{RUBY_VERSION}"

# Define a Greeter class
class Greeter
  def initialize(name)
    @name = name
    @greet_count = 0
  end

  def greet
    @greet_count += 1
    message = "Hello, #{@name}! (greeted #{@greet_count} time(s))"
    puts message
    message
  end
end

# Define a Counter class
class Counter
  def initialize
    @count = 0
  end

  def increment
    @count += 1
    puts "Counter: #{@count}"
    @count
  end

  def reset
    @count = 0
    puts "Counter reset to 0"
  end
end

# Define a utility module
module MathUtils
  def self.fibonacci(n)
    return n if n <= 1
    fibonacci(n - 1) + fibonacci(n - 2)
  end

  def self.factorial(n)
    return 1 if n <= 1
    n * factorial(n - 1)
  end
end

# Create instances
greeter = Greeter.new("World")
counter = Counter.new

# Initial greeting
puts "\n--- Initial Setup ---"
greeter.greet

# Access the DOM using Native
require 'native'

# Setup button handlers
`
  document.addEventListener('DOMContentLoaded', function() {
    const greetBtn = document.getElementById('greet-btn');
    const countBtn = document.getElementById('count-btn');
    const calculateBtn = document.getElementById('calculate-btn');

    if (greetBtn) {
      greetBtn.addEventListener('click', function() {
        #{greeter.greet}
      });
    }

    if (countBtn) {
      countBtn.addEventListener('click', function() {
        #{counter.increment}
      });
    }

    if (calculateBtn) {
      calculateBtn.addEventListener('click', function() {
        const n = 10;
        console.log('Calculating Fibonacci(' + n + ')...');
        const result = #{MathUtils.fibonacci(10)};
        console.log('Fibonacci(' + n + ') = ' + result);
      });
    }

    console.log('✅ Event handlers registered!');
  });
`

puts "\n--- Ready! ---"
puts "Click the buttons to interact with Ruby code"
puts "Try editing this file and see HMR in action!"

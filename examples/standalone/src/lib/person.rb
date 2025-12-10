# backtick_javascript: true
# Person class - Try editing this file to test HMR with dependencies!

class Person
  attr_reader :name, :age

  def initialize(name, age)
    @name = name
    @age = age
  end

  # Try changing this greeting message and save!
  def greet
    "Hello, I'm #{@name} and I'm #{@age} years old! 🙋"
  end

  def birthday
    @age += 1
    puts "🎂 Happy birthday #{@name}! Now #{@age} years old."
  end

  # Try changing this description format!
  def describe
    "Person(name: #{@name}, age: #{@age})"
  end
end

puts "✅ Person class loaded"

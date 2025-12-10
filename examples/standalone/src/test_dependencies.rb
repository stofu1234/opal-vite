# backtick_javascript: true
# Test file for multi-file dependencies

puts "\n=== Testing Multi-File Dependencies ==="

# Test requiring modules
require 'lib/calculator'
require 'lib/formatter'

puts "\n--- Calculator Tests ---"
puts "5 + 3 = #{Calculator.add(5, 3)}"
puts "10 - 4 = #{Calculator.subtract(10, 4)}"
puts "6 × 7 = #{Calculator.multiply(6, 7)}"
puts "20 ÷ 4 = #{Calculator.divide(20, 4)}"
puts "2 ^ 8 = #{Calculator.power(2, 8)}"

puts "\n--- Formatter Tests ---"
puts Formatter.format_add(15, 25)
puts Formatter.format_multiply(8, 9)
puts "Number 42 is: #{Formatter.describe_number(42)}"
puts "Number -5 is: #{Formatter.describe_number(-5)}"
puts "Number 150 is: #{Formatter.describe_number(150)}"

puts "\n--- Dependency Chain Test ---"
puts "✅ All dependencies loaded successfully!"
puts "   test_dependencies.rb -> formatter.rb -> calculator.rb"

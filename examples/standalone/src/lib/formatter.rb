# backtick_javascript: true
# A formatter module that depends on calculator

require 'lib/calculator'

module Formatter
  def self.format_calculation(operation, a, b, result)
    "#{a} #{operation} #{b} = #{result}"
  end

  def self.format_add(a, b)
    result = Calculator.add(a, b)
    format_calculation('+', a, b, result)
  end

  def self.format_multiply(a, b)
    result = Calculator.multiply(a, b)
    format_calculation('×', a, b, result)
  end

  def self.describe_number(n)
    if n == 0
      "zero"
    elsif n == 1
      "one"
    elsif n < 0
      "negative (#{n})"
    elsif n > 100
      "large (#{n})"
    else
      "#{n}"
    end
  end
end

puts "Formatter module loaded (depends on Calculator)"

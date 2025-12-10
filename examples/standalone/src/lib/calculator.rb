# backtick_javascript: true
# A simple calculator module to test dependency resolution

module Calculator
  def self.add(a, b)
    a + b
  end

  def self.subtract(a, b)
    a - b
  end

  def self.multiply(a, b)
    a * b
  end

  def self.divide(a, b)
    raise ArgumentError, "Cannot divide by zero" if b == 0
    a.to_f / b
  end

  def self.power(base, exponent)
    base ** exponent
  end
end

puts "Calculator module loaded"

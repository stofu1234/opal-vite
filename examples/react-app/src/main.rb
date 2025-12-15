require 'native'

puts "🚀 Opal + React + Vite Example"
puts "Ruby version: #{RUBY_VERSION}"
puts "Opal version: #{Opal::VERSION}"
puts "Platform: #{RUBY_PLATFORM}"

# This Ruby code orchestrates the React app
# React components are defined in JSX files and imported by main_loader.js

class AppOrchestrator
  def self.initialize_app
    puts "✅ Initializing React app from Ruby..."

    # You can add Ruby logic here to:
    # - Fetch initial data
    # - Set up global state
    # - Configure the app
    # - Add event listeners
    # - Interact with JavaScript APIs

    setup_console_commands
    log_environment_info
  end

  def self.setup_console_commands
    # Expose Ruby methods to JavaScript console
    `window.rubyCommands = {
      greet: #{method(:greet)},
      calculate: #{method(:calculate)},
      getInfo: #{method(:get_info)}
    }`

    puts "✅ Ruby commands available in console:"
    puts "   - rubyCommands.greet('YourName')"
    puts "   - rubyCommands.calculate(5, 3)"
    puts "   - rubyCommands.getInfo()"
  end

  def self.greet(name)
    message = "Hello, #{name}! This greeting comes from Ruby! 💎"
    puts message
    `alert(#{message})`
    message
  end

  def self.calculate(a, b)
    result = {
      sum: a + b,
      product: a * b,
      difference: a - b,
      quotient: b != 0 ? a / b : 'undefined'
    }
    puts "Calculation result: #{result}"
    Native(result)
  end

  def self.get_info
    info = {
      ruby_version: RUBY_VERSION,
      opal_version: Opal::VERSION,
      platform: RUBY_PLATFORM,
      time: Time.now.to_s
    }
    puts "System info: #{info}"
    Native(info)
  end

  def self.log_environment_info
    puts ""
    puts "=" * 50
    puts "Environment Information"
    puts "=" * 50
    puts "Ruby Version: #{RUBY_VERSION}"
    puts "Opal Version: #{Opal::VERSION}"
    puts "Platform: #{RUBY_PLATFORM}"
    puts "Time: #{Time.now}"
    puts "=" * 50
    puts ""
  end
end

# Initialize when DOM is ready
`
document.addEventListener('DOMContentLoaded', function() {
  console.log('✅ DOM ready, initializing from Ruby...');
`
  AppOrchestrator.initialize_app
`
  console.log('✅ Ruby initialization complete!');
});
`

puts "✅ Ruby code loaded successfully!"
puts "   React components will be mounted by JavaScript"
puts "   Try the commands in the browser console!"

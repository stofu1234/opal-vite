# backtick_javascript: true
require 'native'

# Load VueHelpers from opal-vite gem
require 'opal_vite/concerns/v1/vue_helpers'

# Load components
require 'components/counter'
require 'components/todo'

puts "Opal + Vue.js 3 + Vite Example"
puts "Ruby version: #{RUBY_VERSION}"

class App
  extend VueHelpers

  def self.initialize_apps
    console_log('Initializing Vue.js apps from Ruby...')

    # Mount Counter app
    CounterApp.mount('#counter-app')
    console_log('Counter app mounted')

    # Mount Todo app
    TodoApp.mount('#todo-app')
    console_log('Todo app mounted')

    console_log('All Vue.js apps initialized!')
  end
end

# Initialize when DOM is ready
App.on_dom_ready do
  App.console_log('DOM ready, starting Vue.js apps...')
  App.initialize_apps
end

puts "Ruby code loaded successfully!"

# backtick_javascript: true
require 'native'
require 'inesita'
require 'inesita-router'

# Provide router method for all components
module Inesita
  module Component
    def router
      @root_component
    end
  end
end

# Load application files
require 'store'
require 'router'
require 'components/home'
require 'components/counter'
require 'components/todo_list'
require 'components/about'

puts "🚀 Inesita + Opal + Vite Example"
puts "Ruby version: #{RUBY_VERSION}"

# Mount the application when DOM is ready
`
document.addEventListener('DOMContentLoaded', function() {
  console.log('✅ DOM ready, mounting Inesita app...');
`
  router = Router.new
  element = Inesita::Browser.query_element('#app')
  router.mount_to(element)
  puts "✅ Inesita app mounted successfully!"
`
  console.log('✅ Inesita app mounted!');
});
`

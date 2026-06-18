# backtick_javascript: true

require 'components/counter'

puts "🚀 OpalComponent example (Ruby #{RUBY_VERSION})"

# Mount the component once the DOM is ready.
mount = proc { Counter.new.mount('#app') }

if `document.readyState === 'loading'`
  `document.addEventListener('DOMContentLoaded', #{mount})`
else
  mount.call
end

# backtick_javascript: true
require 'native'
require 'snabberb'
require 'components/counter'
require 'components/todo_app'

# Wait for DOM to be ready
`document.addEventListener('DOMContentLoaded', function() {`
  puts 'DOM ready, mounting Snabberb components...'

  # Mount Counter component
  Counter.attach('counter-app')
  puts 'Counter mounted!'

  # Mount Todo component
  TodoApp.attach('todo-app')
  puts 'TodoApp mounted!'

  puts 'All Snabberb components initialized!'
`})`

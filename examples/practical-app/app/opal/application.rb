# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load concerns
require 'concerns/js_proxy_ex'
require 'concerns/toastable'
require 'concerns/dom_helpers'
require 'concerns/storable'

# Load controllers
require 'controllers/todo_controller'
require 'controllers/form_controller'
require 'controllers/modal_controller'
require 'controllers/toast_controller'
require 'controllers/theme_controller'

puts "Practical App - Todo with Opal"
puts "Ruby version: #{RUBY_VERSION}"

# Register all controllers
StimulusController.register_all!
puts "All controllers registered!"

# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load concerns from opal-vite gem (automatically available when includeConcerns: true)
require 'opal_vite/concerns/js_proxy_ex'
require 'opal_vite/concerns/toastable'
require 'opal_vite/concerns/dom_helpers'
require 'opal_vite/concerns/storable'
require 'opal_vite/concerns/stimulus_helpers'

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

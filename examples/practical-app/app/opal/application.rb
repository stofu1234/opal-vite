# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load StimulusHelpers from opal-vite gem
require 'opal_vite/concerns/v1/stimulus_helpers'

# Load services
require 'services/todo_storage_service'
require 'services/todo_presenter'

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

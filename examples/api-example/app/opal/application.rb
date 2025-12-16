# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load StimulusHelpers from opal-vite gem
require 'opal_vite/concerns/stimulus_helpers'

# Load controllers
require 'controllers/users_controller'
require 'controllers/user_modal_controller'

puts "API Example - Opal + Fetch API"
puts "Ruby version: #{RUBY_VERSION}"

# Register all controllers
StimulusController.register_all!
puts "All controllers registered!"

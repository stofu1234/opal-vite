# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load StimulusHelpers from opal-vite gem
require 'opal_vite/concerns/v1/stimulus_helpers'

# Load all controllers
require 'controllers/accordion_controller'
require 'controllers/dropdown_controller'
require 'controllers/toggle_controller'
require 'controllers/tooltip_controller'
require 'controllers/tabs_controller'

puts "Stimulus Components + Opal + Vite Example"
puts "Ruby version: #{RUBY_VERSION}"

# Register all Stimulus controllers
StimulusController.register_all!

puts "All controllers registered!"

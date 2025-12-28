# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load StimulusHelpers from opal-vite gem
require 'opal_vite/concerns/v1/stimulus_helpers'

# Load controllers
require 'controllers/tabs_controller'
require 'controllers/panel_controller'

puts "Tabs App - Stimulus Outlets & Dispatch Demo"
puts "Ruby version: #{RUBY_VERSION}"

# Register all Stimulus controllers
StimulusController.register_all!

puts "All controllers registered!"

# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load controllers
require 'controllers/form_validation_controller'

puts "Form Validation Example - Opal + Stimulus"
puts "Ruby version: #{RUBY_VERSION}"

# Register all controllers
StimulusController.register_all!
puts "All controllers registered!"

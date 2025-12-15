# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load controllers
require 'controllers/i18n_controller'

puts "i18n Example - Opal + Stimulus"
puts "Ruby version: #{RUBY_VERSION}"

# Register all controllers
StimulusController.register_all!
puts "All controllers registered!"

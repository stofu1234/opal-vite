# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load concerns
require 'concerns/js_proxy_ex'
require 'concerns/toastable'
require 'concerns/dom_helpers'
require 'concerns/storable'

# Load controllers
require 'controllers/form_validation_controller'

puts "Form Validation Example - Opal + Stimulus"
puts "Ruby version: #{RUBY_VERSION}"

# Register all controllers
StimulusController.register_all!
puts "All controllers registered!"

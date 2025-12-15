# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load concerns from opal-vite gem (automatically available when includeConcerns: true)
require 'opal_vite/concerns/js_proxy_ex'
require 'opal_vite/concerns/toastable'
require 'opal_vite/concerns/dom_helpers'

# Load controllers
require 'controllers/chart_controller'
require 'controllers/dashboard_controller'

puts "Chart App - Data Visualization Demo"
puts "Ruby version: #{RUBY_VERSION}"

# Register all controllers
StimulusController.register_all!
puts "All controllers registered!"

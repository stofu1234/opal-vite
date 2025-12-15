# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load controllers
require 'controllers/chart_controller'
require 'controllers/data_chart_controller'
require 'controllers/dashboard_controller'

puts "Chart App - Data Visualization Demo"
puts "Ruby version: #{RUBY_VERSION}"

# Register all controllers
StimulusController.register_all!
puts "All controllers registered!"

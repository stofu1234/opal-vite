# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load controllers
require 'controllers/turbo_navigation_controller'
require 'controllers/turbo_frame_controller'
require 'controllers/turbo_stream_controller'

puts "Turbo + Opal + Vite Example"
puts "Ruby version: #{RUBY_VERSION}"

# Register all controllers
StimulusController.register_all!
puts "All controllers registered!"

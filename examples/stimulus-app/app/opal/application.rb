# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load all controllers
require 'controllers/hello_controller'
require 'controllers/counter_controller'
require 'controllers/clipboard_controller'
require 'controllers/slideshow_controller'

puts "Stimulus + Opal + Vite Example"
puts "Ruby version: #{RUBY_VERSION}"

# Register all Stimulus controllers
StimulusController.register_all!

puts "All controllers registered!"

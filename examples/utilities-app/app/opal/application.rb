# backtick_javascript: true

require 'native'
require 'opal_stimulus/stimulus_controller'

# Load all OpalVite concerns (including StimulusHelpers, URIHelpers, Base64Helpers)
require 'opal_vite/concerns/v1'

# Load controllers
require 'controllers/url_demo_controller'
require 'controllers/base64_demo_controller'
require 'controllers/validation_demo_controller'
require 'controllers/clipboard_demo_controller'

puts 'Utilities App loaded!'
puts "Ruby version: #{RUBY_VERSION}"

# Register all Stimulus controllers
StimulusController.register_all!

puts 'All controllers registered!'

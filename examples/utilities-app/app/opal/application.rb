# backtick_javascript: true

require 'native'
require 'opal_stimulus/stimulus_controller'
require 'opal_vite/concerns/v1'

# Load controllers
require_relative 'controllers/url_demo_controller'
require_relative 'controllers/base64_demo_controller'
require_relative 'controllers/validation_demo_controller'
require_relative 'controllers/clipboard_demo_controller'

puts 'Utilities App loaded!'

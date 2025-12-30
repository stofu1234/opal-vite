# backtick_javascript: true

require 'native'
require 'opal_stimulus/stimulus_controller'

# Load all OpalVite concerns
require 'opal_vite/concerns/v1'

# Load controllers
require 'controllers/chat_controller'

puts 'ActionCable App loaded!'

# Register all Stimulus controllers
StimulusController.register_all!

puts 'All controllers registered!'

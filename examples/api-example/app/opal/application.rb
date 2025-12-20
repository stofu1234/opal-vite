# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load StimulusHelpers from opal-vite gem
require 'opal_vite/concerns/v1/stimulus_helpers'

# Load services (API communication layer)
require 'services/user_service'

# Load presenters (display/rendering layer)
require 'presenters/user_presenter'
require 'presenters/post_presenter'

# Load controllers (UI coordination layer)
require 'controllers/users_controller'
require 'controllers/user_modal_controller'

puts "API Example - Opal + Fetch API"
puts "Ruby version: #{RUBY_VERSION}"
puts "Architecture: Service + Presenter pattern"

# Register all controllers
StimulusController.register_all!
puts "All controllers registered!"

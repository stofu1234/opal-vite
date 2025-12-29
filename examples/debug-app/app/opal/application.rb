# backtick_javascript: true

require 'native'
require 'opal_stimulus/stimulus_controller'

# Load all OpalVite concerns (including DebugHelpers)
require 'opal_vite/concerns/v1'

# Load controllers
require 'controllers/debug_demo_controller'
require 'controllers/group_demo_controller'
require 'controllers/perf_demo_controller'
require 'controllers/toggle_demo_controller'
require 'controllers/assert_demo_controller'
require 'controllers/count_demo_controller'
require 'controllers/table_demo_controller'
require 'controllers/stimulus_demo_controller'

puts 'Debug App loaded!'
puts "Ruby version: #{RUBY_VERSION}"

# Register all Stimulus controllers
StimulusController.register_all!

puts 'All controllers registered!'

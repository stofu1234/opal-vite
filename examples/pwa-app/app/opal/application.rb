# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load concerns from opal-vite gem (automatically available when includeConcerns: true)
require 'opal_vite/concerns/v1/js_proxy_ex'
require 'opal_vite/concerns/v1/toastable'
require 'opal_vite/concerns/v1/dom_helpers'
require 'opal_vite/concerns/v1/storable'

# Load controllers
require 'controllers/pwa_controller'
require 'controllers/offline_detector_controller'

puts "PWA Example - Opal + Stimulus"
puts "Ruby version: #{RUBY_VERSION}"

# Register all controllers
StimulusController.register_all!
puts "All controllers registered!"

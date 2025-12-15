# backtick_javascript: true
require 'opal'
require 'native'
require 'opal_stimulus/stimulus_controller'
require 'controllers/pwa_controller'
require 'controllers/offline_detector_controller'

# Get the Stimulus application from the global scope
StimulusApplication = Native(`window.StimulusApplication`)

# Register all controllers
StimulusApplication.register('pwa', PwaController)
StimulusApplication.register('offline-detector', OfflineDetectorController)

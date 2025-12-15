# backtick_javascript: true
require 'opal'
require 'opal_stimulus/stimulus_controller'
require 'controllers/pwa_controller'
require 'controllers/offline_detector_controller'

# Register all controllers
StimulusApplication.register('pwa', PwaController)
StimulusApplication.register('offline-detector', OfflineDetectorController)

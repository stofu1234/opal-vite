require 'opal'
require 'opal_stimulus'
require_relative 'controllers/pwa_controller'
require_relative 'controllers/offline_detector_controller'

# Register all controllers
StimulusApplication.register('pwa', PwaController)
StimulusApplication.register('offline-detector', OfflineDetectorController)

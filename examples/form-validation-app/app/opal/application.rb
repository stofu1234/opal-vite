# backtick_javascript: true
require 'opal'
require 'native'
require 'opal_stimulus/stimulus_controller'
require 'controllers/form_validation_controller'

# Get the Stimulus application from the global scope
StimulusApplication = Native(`window.StimulusApplication`)

# Register all controllers
StimulusApplication.register('form-validation', FormValidationController)

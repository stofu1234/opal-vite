# backtick_javascript: true
require 'opal'
require 'opal_stimulus/stimulus_controller'
require 'controllers/form_validation_controller'

# Register all controllers
StimulusApplication.register('form-validation', FormValidationController)

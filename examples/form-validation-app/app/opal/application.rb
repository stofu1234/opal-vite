require 'opal'
require 'opal_stimulus'
require_relative 'controllers/form_validation_controller'

# Register all controllers
StimulusApplication.register('form-validation', FormValidationController)

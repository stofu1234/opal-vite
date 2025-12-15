# backtick_javascript: true
require 'opal'
require 'native'
require 'opal_stimulus/stimulus_controller'
require 'controllers/i18n_controller'

# Get the Stimulus application from the global scope
StimulusApplication = Native(`window.StimulusApplication`)

# Register all controllers
StimulusApplication.register('i18n', I18nController)

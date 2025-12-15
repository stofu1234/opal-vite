# backtick_javascript: true
require 'opal'
require 'opal_stimulus/stimulus_controller'
require 'controllers/i18n_controller'

# Register all controllers
StimulusApplication.register('i18n', I18nController)

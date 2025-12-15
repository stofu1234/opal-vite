require 'opal'
require 'opal_stimulus'
require_relative 'controllers/i18n_controller'

# Register all controllers
StimulusApplication.register('i18n', I18nController)

# backtick_javascript: true
# Backward compatibility wrapper - delegates to v1
require 'opal_vite/concerns/v1/stimulus_helpers'

`console.warn("[DEPRECATION] require 'opal_vite/concerns/stimulus_helpers' is deprecated. Please use require 'opal_vite/concerns/v1/stimulus_helpers' instead.")`

# Alias old module path for backward compatibility
module OpalVite
  module Concerns
    StimulusHelpers = V1::StimulusHelpers
  end
end

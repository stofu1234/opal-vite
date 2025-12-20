# backtick_javascript: true
# Backward compatibility wrapper - delegates to v1
require 'opal_vite/concerns/v1/storable'

`console.warn("[DEPRECATION] require 'opal_vite/concerns/storable' is deprecated. Please use require 'opal_vite/concerns/v1/storable' instead.")`

# Alias old module path for backward compatibility
module OpalVite
  module Concerns
    Storable = V1::Storable
  end
end

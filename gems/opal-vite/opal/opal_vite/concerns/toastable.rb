# backtick_javascript: true
# Backward compatibility wrapper - delegates to v1
require 'opal_vite/concerns/v1/toastable'

`console.warn("[DEPRECATION] require 'opal_vite/concerns/toastable' is deprecated. Please use require 'opal_vite/concerns/v1/toastable' instead.")`

# Alias old module path for backward compatibility
module OpalVite
  module Concerns
    Toastable = V1::Toastable
  end
end

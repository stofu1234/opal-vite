# backtick_javascript: true
# Backward compatibility wrapper - delegates to v1
require 'opal_vite/concerns/v1/vue_helpers'

`console.warn("[DEPRECATION] require 'opal_vite/concerns/vue_helpers' is deprecated. Please use require 'opal_vite/concerns/v1/vue_helpers' instead.")`

# Alias old module path for backward compatibility
module OpalVite
  module Concerns
    VueHelpers = V1::VueHelpers
  end
end

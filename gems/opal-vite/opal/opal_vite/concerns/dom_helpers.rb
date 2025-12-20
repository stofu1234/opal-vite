# backtick_javascript: true
# Backward compatibility wrapper - delegates to v1
require 'opal_vite/concerns/v1/dom_helpers'

`console.warn("[DEPRECATION] require 'opal_vite/concerns/dom_helpers' is deprecated. Please use require 'opal_vite/concerns/v1/dom_helpers' instead.")`

# Alias old module path for backward compatibility
module OpalVite
  module Concerns
    DomHelpers = V1::DomHelpers
  end
end

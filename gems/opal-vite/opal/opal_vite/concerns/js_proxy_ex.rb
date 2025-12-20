# backtick_javascript: true
# Backward compatibility wrapper - delegates to v1
require 'opal_vite/concerns/v1/js_proxy_ex'

`console.warn("[DEPRECATION] require 'opal_vite/concerns/js_proxy_ex' is deprecated. Please use require 'opal_vite/concerns/v1/js_proxy_ex' instead.")`

# Alias old module path for backward compatibility
module OpalVite
  module Concerns
    JsProxyEx = V1::JsProxyEx
  end
end

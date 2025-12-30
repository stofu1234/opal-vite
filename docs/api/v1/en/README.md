# OpalVite Helpers API v1

This directory contains API documentation for OpalVite Concerns v1.

## Module Structure

All helpers are located in the `OpalVite::Concerns::V1` namespace:

```ruby
require 'opal_vite/concerns/v1/stimulus_helpers'

class MyController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers
end
```

## Available Modules

| Module | Description |
|--------|-------------|
| [StimulusHelpers](stimulus_helpers.md) | Stimulus controller integration |
| [DomHelpers](dom_helpers.md) | DOM manipulation utilities |
| [Storable](storable.md) | LocalStorage persistence |
| [Toastable](toastable.md) | Toast notification system |
| [JsProxyEx](js_proxy_ex.md) | JavaScript object wrappers |
| [VueHelpers](vue_helpers.md) | Vue.js 3 integration |
| [ReactHelpers](react_helpers.md) | React integration |
| [URIHelpers](uri_helpers.md) | URL encoding/decoding utilities |
| [Base64Helpers](base64_helpers.md) | Base64 encoding/decoding utilities |
| [DebugHelpers](debug_helpers.md) | Debugging and console logging utilities |
| [ActionCableHelpers](action_cable_helpers.md) | ActionCable WebSocket integration |
| [TurboHelpers](turbo_helpers.md) | Hotwire Turbo integration |

## Backward Compatibility

For backward compatibility, you can still use the old paths:

```ruby
require 'opal_vite/concerns/stimulus_helpers'
include OpalVite::Concerns::StimulusHelpers
```

However, this will show a deprecation warning. Please migrate to the v1 paths.

## Global Aliases

For convenience, top-level aliases are also available:

```ruby
require 'opal_vite/concerns/v1/stimulus_helpers'
include StimulusHelpers  # Same as OpalVite::Concerns::V1::StimulusHelpers
```

# OpalVite Helpers API v1

This section contains API documentation for OpalVite Concerns v1.

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
| [StimulusHelpers](en/stimulus_helpers.md) | Stimulus controller integration |
| [DomHelpers](en/dom_helpers.md) | DOM manipulation utilities |
| [Storable](en/storable.md) | LocalStorage persistence |
| [Toastable](en/toastable.md) | Toast notification system |
| [JsProxyEx](en/js_proxy_ex.md) | JavaScript object wrappers |
| [VueHelpers](en/vue_helpers.md) | Vue.js 3 integration |
| [ReactHelpers](en/react_helpers.md) | React integration |

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

## Language

- [English](en/README.md)
- [日本語](ja/README.md)

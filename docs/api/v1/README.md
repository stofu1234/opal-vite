# OpalVite Helpers API v1

API documentation for OpalVite Concerns v1.

## Languages / 言語

- [English](en/README.md)
- [日本語](ja/README.md)

## Quick Start

```ruby
require 'opal_vite/concerns/v1/stimulus_helpers'

class MyController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers
  include OpalVite::Concerns::V1::Storable
  include OpalVite::Concerns::V1::Toastable
end
```

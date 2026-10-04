# opal_stimulus Compatibility Patch

`opal_vite/compat/opal_stimulus` fixes accessors in
[opal_stimulus](https://github.com/josephschito/opal_stimulus) 0.2.x that look
up the wrong JavaScript property for multi-word names.

## Usage

```ruby
require 'opal_stimulus/stimulus_controller'
require 'opal_vite/compat/opal_stimulus'   # before defining controllers

class PlayerController < StimulusController
  self.targets = ["soundButton"]
  self.values  = { latest_paid: :number }
  self.outlets = ["user-status"]
  self.classes = ["active"]
end
```

The patch is opt-in. It is safe to keep after opal_stimulus is fixed upstream.

## What It Fixes

| Declaration | Without the patch | With the patch |
|-------------|-------------------|----------------|
| `self.targets = ["soundButton"]` | `has_sound_button_target` reads `hasSoundbuttonTarget` (always undefined) | reads `hasSoundButtonTarget` |
| `self.values = { latest_paid: :number }` | registers `latest_paid` with Stimulus: the attribute becomes `data-x-latest_paid-value`, `latest_paid_value` reads `latest_paidValue` (undefined), `latest_paid_value_changed` never fires | registers `latestPaid`: `data-x-latest-paid-value`, `latestPaidValue`, `hasLatestPaidValue`, `latestPaidValueChanged` |
| `self.outlets = ["user-status"]` | `user-status_outlet` etc. read `user-statusOutlet`; callbacks never fire | `user_status_outlet`, `user_status_outlets`, `has_user_status_outlet`, `user_status_outlet_connected` / `_disconnected` |
| `self.classes = ["active"]` (multi-word keys) | `has_*_class` uses `String#capitalize` | first letter upcased only, like Stimulus |

Single-word names behave the same with or without the patch.

## Notes

- `values=` is replaced rather than wrapped, because the original registers
  the snake_case key with Stimulus and that changes the data attribute name.
- Ruby method names are unchanged (`latest_paid_value`, `has_latest_paid`, ...).

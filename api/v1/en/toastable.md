# Toastable API

Toast notification helpers.

## Usage

```ruby
require 'opal_vite/concerns/v1/toastable'

class MyController < StimulusController
  include OpalVite::Concerns::V1::Toastable
end
```

---

## Methods

### dispatch_toast(message, type = 'info')
Dispatch toast notification

```ruby
dispatch_toast('Operation completed', 'success')
dispatch_toast('An error occurred', 'error')
```

### show_success(message)
Show success notification (green)

```ruby
show_success('Saved successfully')
```

### show_error(message)
Show error notification (red)

```ruby
show_error('Save failed')
```

### show_warning(message)
Show warning notification (yellow)

```ruby
show_warning('Please check your input')
```

### show_info(message)
Show info notification (blue)

```ruby
show_info('You have new messages')
```

---

## Toast Controller Implementation

To display toasts, you need a Toast controller that listens for `show-toast` events:

```ruby
class ToastController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  def connect
    on_window_event('show-toast') do |event|
      detail = event.detail
      show_toast(detail.message, detail.type)
    end
  end

  def show_toast(message, type)
    # Toast display logic
  end
end
```

---

## Example

```ruby
class FormController < StimulusController
  include OpalVite::Concerns::V1::Toastable
  include OpalVite::Concerns::V1::StimulusHelpers

  def submit
    if valid?
      save_data
      show_success('Form submitted successfully')
    else
      show_error('Please correct the errors')
    end
  end
end
```

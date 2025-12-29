# TurboHelpers

Ruby-friendly DSL for Hotwire Turbo integration from Opal/Stimulus controllers.

## Prerequisites

```javascript
// In your main.js
import * as Turbo from "@hotwired/turbo"
window.Turbo = Turbo
```

## Usage

```ruby
class NavigationController < StimulusController
  include OpalVite::Concerns::V1::TurboHelpers

  def navigate(event)
    prevent_default
    turbo_visit("/dashboard")
  end

  def refresh_frame
    reload_turbo_frame("notifications")
  end
end
```

## Turbo Drive

### `turbo_visit(url, options = {})`

Navigate to a URL using Turbo Drive.

```ruby
turbo_visit("/users/1")
turbo_visit("/login", action: "replace")
turbo_visit("/modal-content", frame: "modal")
```

Options:
- `:action` - "advance" (default), "replace", or "restore"
- `:frame` - Target frame ID

### `turbo_replace(url)`

Navigate replacing the current history entry.

```ruby
turbo_replace("/dashboard")
```

### `turbo_clear_cache`

Clear the Turbo Drive cache.

### `turbo_enable` / `turbo_disable`

Enable or disable Turbo Drive globally.

### `turbo_enabled?`

Check if Turbo Drive is enabled.

### `turbo_progress_delay(delay)`

Set Turbo Drive progress bar delay in milliseconds.

## Turbo Frames

### `get_turbo_frame(frame_id)`

Get a Turbo Frame element by ID.

```ruby
frame = get_turbo_frame("modal")
```

### `reload_turbo_frame(frame_id, url = nil)`

Reload a Turbo Frame.

```ruby
reload_turbo_frame("notifications")
reload_turbo_frame("sidebar", "/sidebar/refresh")
```

### `set_frame_src(frame_id, url)`

Set the src attribute of a Turbo Frame.

```ruby
set_frame_src("content", "/new-content")
```

### `disable_turbo_frame(frame_id)` / `enable_turbo_frame(frame_id)`

Disable or enable a Turbo Frame.

### `frame_loading?(frame_id)`

Check if a Turbo Frame is loading.

### `on_frame_loaded(frame_id, &block)`

Wait for a Turbo Frame to finish loading.

```ruby
on_frame_loaded("modal") do
  init_form_validation
end
```

### `event_turbo_frame`

Get the target frame from current event.

## Turbo Streams

### `turbo_stream(action, target, html = nil)`

Render a Turbo Stream action.

```ruby
turbo_stream(:append, "messages", "<div>New message</div>")
turbo_stream(:remove, "message_1")
```

Actions: `:append`, `:prepend`, `:replace`, `:update`, `:remove`, `:before`, `:after`

### Convenience Methods

```ruby
turbo_append("messages", "<div>New</div>")
turbo_prepend("alerts", "<div>Alert!</div>")
turbo_replace_element("user_1", "<div>Updated</div>")
turbo_update("counter", "<span>5</span>")
turbo_remove("item_1")
turbo_before("item_2", "<div>Before</div>")
turbo_after("item_2", "<div>After</div>")
```

### `turbo_streams(&block)`

Create multiple Turbo Stream operations.

```ruby
turbo_streams do |s|
  s.append("messages", "<div>Message 1</div>")
  s.prepend("notifications", "<div>Alert!</div>")
  s.remove("loading-indicator")
end
```

### `render_turbo_stream(stream_html)`

Render raw Turbo Stream HTML.

## Turbo Events

### `on_turbo(event_name, &block)`

Listen for Turbo Drive events.

```ruby
on_turbo("before-visit") { |e| validate_form }
on_turbo("load") { init_components }
```

### Event-Specific Listeners

```ruby
on_turbo_before_visit { |e| ... }  # Before navigation
on_turbo_visit { |e| ... }         # Navigation started
on_turbo_load { |e| ... }          # Page fully loaded
on_turbo_render { |e| ... }        # Page rendered
on_turbo_before_fetch { |e| ... }  # Before fetch request
on_turbo_submit_start { |e| ... }  # Form submission started
on_turbo_submit_end { |e| ... }    # Form submission ended
on_turbo_frame_load { |e| ... }    # Frame loaded
on_turbo_before_stream { |e| ... } # Before stream renders
```

## Form Helpers

### `turbo_submit(form_element)`

Submit a form via Turbo.

```ruby
form = query("[data-chat-target='form']")
turbo_submit(form)
```

### `turbo_submit_to_frame(form_element, frame_id)`

Submit a form with custom target frame.

### `disable_turbo_form(form_element)` / `enable_turbo_form(form_element)`

Disable or enable Turbo on a specific form.

## Stream over SSE

### `turbo_stream_from(url)`

Connect to a Turbo Stream over SSE endpoint.

```ruby
source = turbo_stream_from("/notifications/stream")
```

### `turbo_stream_disconnect(source)`

Disconnect a Turbo Stream SSE source.

## Utility Methods

### `turbo_available?`

Check if Turbo is available.

### `turbo_current_url`

Get current Turbo Drive visit location.

### `turbo_cancel_visit`

Cancel a pending Turbo visit.

### `turbo_refresh(options = {})`

Refresh the page using Turbo's morph feature.

### `turbo_loading_class(element, class_name = "turbo-loading")`

Add loading class during Turbo navigation.

```ruby
turbo_loading_class(get_target(:button), "loading")
```

## Example: SPA Navigation

```ruby
class NavigationController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers
  include OpalVite::Concerns::V1::TurboHelpers

  self.targets = %w[link spinner]

  def connect
    on_turbo_before_fetch { show_spinner }
    on_turbo_load { hide_spinner }
  end

  def navigate(event)
    prevent_default
    url = event_data("url")
    turbo_visit(url)
  end

  def load_in_frame(event)
    prevent_default
    url = event_data("url")
    frame_id = event_data("frame")
    set_frame_src(frame_id, url)
  end

  private

  def show_spinner
    show_target(:spinner)
  end

  def hide_spinner
    hide_target(:spinner)
  end
end
```

## Example: Modal with Turbo Frames

```ruby
class ModalController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers
  include OpalVite::Concerns::V1::TurboHelpers

  self.targets = %w[frame overlay]

  def open(event)
    prevent_default
    url = event_data("modal-url")

    show_target(:overlay)
    set_frame_src("modal-frame", url)

    on_frame_loaded("modal-frame") do
      element_add_class("is-open")
    end
  end

  def close
    element_remove_class("is-open")
    hide_target(:overlay)
    turbo_update("modal-frame", "")
  end

  def submit_success
    close
    reload_turbo_frame("main-content")
  end
end
```

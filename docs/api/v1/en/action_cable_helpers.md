# ActionCableHelpers

Ruby-friendly DSL for ActionCable WebSocket communication from Opal/Stimulus controllers.

## Prerequisites

```javascript
// In your main.js
import { createConsumer } from "@rails/actioncable"
window.ActionCable = { createConsumer }
```

## Usage

```ruby
class ChatController < StimulusController
  include OpalVite::Concerns::V1::ActionCableHelpers

  def connect
    cable_connect("/cable")
    cable_subscribe("ChatChannel",
      params: { room_id: 1 },
      on_received: ->(data) { handle_message(data) }
    )
  end

  def disconnect
    cable_disconnect
  end

  def send_message
    cable_perform(:speak, message: target_value(:input))
  end
end
```

## Consumer Management

### `cable_connect(url = "/cable")`

Create and store an ActionCable consumer.

```ruby
cable_connect("/cable")
cable_connect("wss://api.example.com/cable")
```

### `cable_consumer`

Get the current ActionCable consumer instance.

### `cable_disconnect`

Disconnect and cleanup the ActionCable consumer.

### `cable_connected?`

Check if ActionCable is connected.

```ruby
if cable_connected?
  cable_perform(:ping)
end
```

## Subscription Management

### `subscribe_to(channel_name, params = {}, &setup_block)`

Subscribe to an ActionCable channel with setup block.

```ruby
subscribe_to("ChatChannel", room_id: 1) do |subscription|
  on_cable_connected(subscription) { puts "Connected!" }
  on_cable_received(subscription) { |data| handle_data(data) }
end
```

### `cable_subscribe(channel_name, params:, on_connected:, on_disconnected:, on_received:, on_rejected:)`

Subscribe with all callbacks in one call.

```ruby
cable_subscribe("NotificationChannel",
  params: { user_id: current_user_id },
  on_connected: -> { show_connected },
  on_received: ->(data) { display_notification(data) }
)
```

### `quick_subscribe(channel_name, params = {}, &on_received)`

Quick subscription for simple channels.

```ruby
quick_subscribe("AlertChannel") do |data|
  show_alert(data["message"])
end
```

### `unsubscribe_from(channel_name, params = {})`

Unsubscribe from a channel.

### `get_subscription(channel_name, params = {})`

Get a subscription by channel name and params.

## Subscription Callbacks

### `on_cable_connected(subscription, &block)`

Set the connected callback.

### `on_cable_disconnected(subscription, &block)`

Set the disconnected callback.

### `on_cable_received(subscription, &block)`

Set the received callback.

```ruby
on_cable_received(subscription) do |data|
  message = cable_data(data, "message")
  display_message(message)
end
```

### `on_cable_rejected(subscription, &block)`

Set the rejected callback.

## Sending Data

### `cable_perform(action, data = {})`

Perform an action on the default subscription.

```ruby
cable_perform(:speak, message: "Hello!")
cable_perform(:typing, user_id: 1)
```

### `perform_on(subscription, action, data = {})`

Perform an action on a specific subscription.

### `cable_send(subscription, data)`

Send raw data on a subscription.

## Broadcast Helpers

### `handle_html_broadcast(data, target_selector, position = :append)`

Handle a broadcast containing HTML to insert.

```ruby
on_cable_received(subscription) do |data|
  handle_html_broadcast(data, "#messages", :append)
end
```

Positions: `:append`, `:prepend`, `:replace`, `:before`, `:after`

### `handle_update_broadcast(data, id_key = "id", content_key = "content")`

Handle a broadcast that updates a specific element.

### `handle_remove_broadcast(data, id_key = "id")`

Handle a broadcast that removes an element.

## Data Extraction

### `cable_data(data, key, default = nil)`

Extract a value from received data.

```ruby
user = cable_data(data, "user")
count = cable_data(data, "count", 0)
```

### `cable_data_json(data, key)`

Extract and parse a JSON string from received data.

### `cable_data_has?(data, key)`

Check if received data has a specific key.

### `cable_data_type(data, type_key = "type")`

Get data type from received data.

### `cable_route(data, handlers, type_key = "type")`

Route incoming data based on type/action.

```ruby
on_cable_received(subscription) do |data|
  cable_route(data, {
    "message" => -> { handle_message(data) },
    "typing" => -> { handle_typing(data) },
    "presence" => -> { handle_presence(data) }
  })
end
```

## Example: Real-time Chat

```ruby
class ChatController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers
  include OpalVite::Concerns::V1::ActionCableHelpers

  self.targets = %w[messages input status]

  def connect
    cable_connect("/cable")
    cable_subscribe("ChatChannel",
      params: { room: "general" },
      on_connected: -> { update_status("online") },
      on_disconnected: -> { update_status("offline") },
      on_received: ->(data) { display_message(data) }
    )
  end

  def disconnect
    cable_disconnect
  end

  def send_message
    text = target_value(:input)
    return if text.empty?

    cable_perform(:speak, text: text)
    target_set_value(:input, "")
  end

  private

  def display_message(data)
    user = cable_data(data, "user")
    text = cable_data(data, "text")
    html = "<p><strong>#{user}:</strong> #{text}</p>"
    handle_html_broadcast({ "html" => html }.to_n, "#messages", :append)
  end

  def update_status(status)
    target_set_text(:status, status)
  end
end
```

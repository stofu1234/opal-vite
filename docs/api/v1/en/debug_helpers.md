# DebugHelpers

Module providing debugging utilities for Opal applications. Outputs structured debug information to the browser console with support for grouping, timing, assertions, and more.

## Usage

```ruby
class MyController < StimulusController
  include OpalVite::Concerns::V1::DebugHelpers

  def connect
    debug_log("Controller connected")
    debug_stimulus_connect
  end

  def some_action
    debug_measure("Heavy Operation") do
      # ... expensive code ...
    end
  end
end
```

## Enabling/Disabling Debug Mode

Debug output is controlled by the `debug_enabled?` method. There are several ways to enable debug mode:

### JavaScript Global Variable

```javascript
// In your main.js or HTML
window.OPAL_DEBUG = true
```

### LocalStorage

```javascript
localStorage.setItem('opal_debug', 'true')
```

### Runtime Toggle

```ruby
debug_enable!   # Enable debug mode
debug_disable!  # Disable debug mode
```

## Basic Logging

### debug_log(message, data = nil)

Log a debug message. Automatically prefixed with `[DEBUG]`.

```ruby
debug_log("User clicked button")
debug_log("Request completed", { status: 200, time: 42 })
```

### debug_warn(message, data = nil)

Log a warning message. Automatically prefixed with `[WARN]`.

```ruby
debug_warn("Deprecated API used")
debug_warn("Slow query detected", { query: sql, time: 1500 })
```

### debug_error(message, error = nil)

Log an error message. Always outputs regardless of debug mode.

```ruby
debug_error("Failed to load data")
debug_error("API error", { code: 500, message: "Internal Server Error" })
```

## Object Inspection

### debug_inspect(obj, label = nil)

Log a Ruby object with its `#inspect` representation.

```ruby
user = { name: "Alice", role: "admin" }
debug_inspect(user, "Current User")
# Output: [INSPECT] Current User: {:name=>"Alice", :role=>"admin"}
```

### debug_table(data)

Display data as a table in the console. Works with arrays of hashes or single hashes.

```ruby
users = [
  { name: "Alice", age: 30 },
  { name: "Bob", age: 25 }
]
debug_table(users)
```

## Grouping

### debug_group(label, &block)

Create an expandable group of debug messages.

```ruby
debug_group("Request Flow") do
  debug_log("Step 1: Validate input")
  debug_log("Step 2: Process data")
  debug_log("Step 3: Send response")
end
```

### debug_group_collapsed(label, &block)

Create a collapsed group (must click to expand).

```ruby
debug_group_collapsed("Request Details") do
  debug_log("URL: /api/users")
  debug_log("Method: GET")
  debug_log("Headers: { ... }")
end
```

## Performance Measurement

### debug_time(label) / debug_time_end(label)

Start/stop a named timer.

```ruby
debug_time("API Request")
# ... async operation ...
debug_time_end("API Request")
# Output: [TIMER] API Request: 245.32ms
```

### debug_measure(label, &block)

Measure and log execution time of a block. Returns the block's result.

```ruby
result = debug_measure("Heavy Calculation") do
  (1..10000).sum
end
# Output: [PERF] Heavy Calculation: 5.23ms
```

## Assertions & Tracing

### debug_assert(condition, message)

Assert a condition. Logs error if condition is false.

```ruby
debug_assert(value > 0, "Value must be positive")
debug_assert(user.present?, "User is required")
```

### debug_trace(message = nil)

Log the current call stack.

```ruby
def deep_method
  debug_trace("How did we get here?")
end
```

## Counting

### debug_count(label)

Count how many times this is called with the given label.

```ruby
def handle_click
  debug_count("button_clicks")
  # Output: [COUNT] button_clicks: 1
  # Next call: [COUNT] button_clicks: 2
end
```

### debug_count_reset(label)

Reset the counter for the given label.

```ruby
debug_count_reset("button_clicks")
```

## Stimulus Integration

### debug_stimulus_connect(controller = nil)

Log when a Stimulus controller connects.

```ruby
def connect
  debug_stimulus_connect
  # Output: [STIMULUS] Connected: my-controller
end
```

### debug_stimulus_disconnect(controller = nil)

Log when a Stimulus controller disconnects.

```ruby
def disconnect
  debug_stimulus_disconnect
end
```

### debug_stimulus_action(action_name, event = nil)

Log a Stimulus action execution.

```ruby
def click(event)
  debug_stimulus_action("click", event)
  # Output: [STIMULUS] Action: click Event: { type: "click", ... }
end
```

## Configuration

### debug_enabled?

Check if debugging is enabled.

```ruby
if debug_enabled?
  # Do expensive debug operations
end
```

### debug_enable! / debug_disable!

Toggle debug mode at runtime. Also persists to localStorage.

```ruby
debug_enable!   # Enable and persist
debug_disable!  # Disable and clear persistence
```

## Example: Full Controller

```ruby
class TodoController < StimulusController
  include OpalVite::Concerns::V1::DebugHelpers
  include OpalVite::Concerns::V1::DomHelpers

  def connect
    debug_stimulus_connect
    debug_log("Initializing todo list")
  end

  def add
    debug_group("Adding Todo") do
      debug_time("todo:add")

      title = input_value
      debug_assert(!title.empty?, "Title cannot be empty")

      debug_measure("Create Todo") do
        create_todo(title)
      end

      debug_count("todos_added")
      debug_time_end("todo:add")
    end
  end

  def disconnect
    debug_stimulus_disconnect
  end
end
```

## Tips

1. **Use in Development Only**: Debug output is disabled by default. Enable only during development.

2. **Group Related Messages**: Use `debug_group` to organize related debug output.

3. **Measure Performance**: Use `debug_measure` to identify slow operations.

4. **Assertions for Validation**: Use `debug_assert` to catch bugs early.

5. **Count for Tracking**: Use `debug_count` to track how often code paths execute.

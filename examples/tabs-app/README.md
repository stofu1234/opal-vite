# Tabs App - Stimulus Outlets & Dispatch Demo

This example demonstrates advanced Stimulus features using Ruby and Opal:

- **Outlets API** - Connecting controllers to access each other
- **stimulus_dispatch()** - Custom events for inter-controller communication
- **Action Parameters** - Passing data from HTML to controller actions
- **Stimulus Values** - Typed value attributes
- **CSS Animations** - Smooth transitions between panels

## Features Demonstrated

### 1. Outlets API

The `TabsController` declares outlets to connect with multiple `PanelController` instances:

```ruby
class TabsController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  # Define outlets connection
  `static outlets = ["panel"]`

  def select
    # Use outlet helpers from StimulusHelpers
    if has_outlet?(:panel)
      # Call hide on all panel controllers
      call_all_outlets(:panel, :hide)
    end
  end
end
```

### 2. stimulus_dispatch() for Events

Controllers communicate via custom events:

```ruby
# TabsController dispatches an event
stimulus_dispatch('change', detail: { index: index })

# PanelController listens for the event
def connect
  on_window_event('tabs:change') do |event|
    handle_change(event)
  end
end
```

### 3. StimulusHelpers Methods Used

This example showcases many helper methods from `OpalVite::Concerns::V1::StimulusHelpers`:

**Outlets:**
- `has_outlet?(name)` - Check if outlet exists
- `get_outlets(name)` - Get array of outlet controllers
- `call_all_outlets(name, method, *args)` - Call method on all outlets

**Action Parameters:**
- `action_param_int(name, default)` - Get integer param from data attributes

**Values API:**
- `get_value(name)` - Get Stimulus value
- `set_value(name, value)` - Set Stimulus value

**Events:**
- `stimulus_dispatch(name, detail:)` - Dispatch custom event
- `on_window_event(name, &block)` - Listen for window events

**Element Classes:**
- `element_add_class(class_name)` - Add class to controller element
- `element_remove_class(class_name)` - Remove class from controller element

**DOM Queries:**
- `query_all_element(selector)` - Query within controller element

**JavaScript Interop:**
- `js_equals?(a, b)` - Check JavaScript strict equality
- `js_get(obj, prop)` - Get JavaScript property
- `js_call_on(obj, method, *args)` - Call method on JavaScript object

## Running the Example

```bash
cd examples/tabs-app
npm install
npm run dev
```

Visit http://localhost:3007

## File Structure

```
tabs-app/
├── index.html                          # Main HTML with tab UI
├── package.json                        # Dependencies
├── vite.config.ts                      # Vite configuration
├── src/
│   └── main.js                         # Entry point, Stimulus setup
└── app/
    └── opal/
        ├── application.rb              # Load controllers
        └── controllers/
            ├── tabs_controller.rb      # Tab management with outlets
            └── panel_controller.rb     # Panel visibility and events
```

## How It Works

### TabsController

1. Declares `panel` outlets to connect with all PanelController instances
2. Uses action parameters to get the selected tab index
3. Calls `hide()` on all panels via outlets
4. Dispatches a `tabs:change` event with the selected index

### PanelController

1. Stores its index using Stimulus values (`data-panel-index-value`)
2. Listens for `tabs:change` events
3. Compares event index with its own index
4. Shows itself if indices match, hides otherwise
5. Exposes `show()` and `hide()` methods callable via outlets

### Communication Flow

```
User clicks tab button
       ↓
TabsController.select(index)
       ↓
   ├─→ call_all_outlets(:panel, :hide)  ← Outlets API
   │
   └─→ stimulus_dispatch('change')       ← Custom Events
              ↓
   PanelController receives event
              ↓
   Shows/hides based on index match
```

## Key Concepts

### Outlets vs Events

This example demonstrates **two ways** for controllers to communicate:

1. **Outlets (Direct)**: `call_all_outlets(:panel, :hide)` - Direct method calls
2. **Events (Loose Coupling)**: `stimulus_dispatch('change')` - Event-based communication

Both approaches have their uses:
- **Outlets**: Better for direct control and synchronous operations
- **Events**: Better for loose coupling and when multiple controllers might listen

### Benefits of Ruby/Opal

All controller logic is written in Ruby:
- Type-safe with Ruby's object model
- Access to Ruby's expressive syntax
- StimulusHelpers provide a Ruby-friendly DSL
- Compiles to efficient JavaScript via Opal

## Learn More

- [Stimulus Outlets Documentation](https://stimulus.hotwired.dev/reference/outlets)
- [Stimulus dispatch() Documentation](https://stimulus.hotwired.dev/reference/controllers#events)
- [Opal Documentation](https://opalrb.com/)
- [StimulusHelpers API Reference](../../docs/STIMULUS_HELPERS_API.md)

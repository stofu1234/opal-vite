# Counter App - Stimulus Values API Demo

A simple counter application demonstrating the Stimulus Values API with Opal.

## Features

This example demonstrates:

1. **Stimulus Values API** with `static values = { count: Number }`
2. **Value Helper Methods**:
   - `get_value(name)` - Get a Stimulus value
   - `set_value(name, value)` - Set a Stimulus value
   - `increment_value(name, amount)` - Increment a numeric value
   - `decrement_value(name, amount)` - Decrement a numeric value
3. **Value Change Callbacks** - Automatic `count_value_changed` method invocation
4. **Targets API** - Using targets to update the display
5. **Visual Feedback** - CSS animations for value changes

## Project Structure

```
counter-app/
├── app/
│   ├── javascript/
│   │   └── application.js          # Stimulus setup and Opal loader
│   ├── opal/
│   │   ├── application.rb          # Main Opal application
│   │   └── controllers/
│   │       └── counter_controller.rb  # Counter controller with Values API
│   └── styles.css                  # Application styles
├── index.html                      # Main HTML file
├── package.json                    # NPM dependencies
├── vite.config.ts                  # Vite configuration
└── README.md                       # This file
```

## Key Implementation Details

### Counter Controller

The `CounterController` demonstrates the Values API:

```ruby
class CounterController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  # Define values using backtick JavaScript
  `static values = { count: Number }`

  self.targets = ["display"]

  def increment
    increment_value(:count)  # Uses the helper method
  end

  def decrement
    decrement_value(:count)  # Uses the helper method
  end

  def reset
    set_value(:count, 0)     # Uses the helper method
  end

  # Automatic callback when value changes
  def count_value_changed
    current_count = get_value(:count)
    puts "Count changed to: #{current_count}"
    update_display
  end
end
```

### HTML Integration

```html
<div data-controller="counter" data-counter-count-value="0">
  <div class="counter-value" data-counter-target="display">0</div>

  <button data-action="click->counter#increment">+ Increment</button>
  <button data-action="click->counter#reset">Reset</button>
  <button data-action="click->counter#decrement">- Decrement</button>
</div>
```

## Getting Started

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start the development server:**
   ```bash
   npm run dev
   ```

3. **Open your browser:**
   Navigate to `http://localhost:3000`

## Available Scripts

- `npm run dev` - Start Vite development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build

## Learning Resources

- [Stimulus Values API](https://stimulus.hotwired.dev/reference/values)
- [Opal Documentation](https://opalrb.com/)
- [Vite Documentation](https://vitejs.dev/)

## Key Concepts

### Stimulus Values API

The Values API provides a clean way to work with typed data in Stimulus controllers:

- **Type Safety**: Values are automatically converted to the specified type (Number, String, Boolean, Array, Object)
- **Data Attributes**: Values are stored in `data-[identifier]-[name]-value` attributes
- **Change Callbacks**: Methods named `[name]ValueChanged` are automatically called when values change
- **Helper Methods**: The StimulusHelpers module provides convenient methods for common operations

### Helper Methods Used

- `get_value(:count)` - Gets the current count value
- `set_value(:count, value)` - Sets the count to a specific value
- `increment_value(:count, amount)` - Increments count by amount (default: 1)
- `decrement_value(:count, amount)` - Decrements count by amount (default: 1)
- `target_set_text(:display, text)` - Sets the text content of a target
- `has_target?(:display)` - Checks if a target exists

## Notes

- The counter starts at 0 (specified in the HTML: `data-counter-count-value="0"`)
- The `count_value_changed` callback is automatically invoked whenever the value changes
- Visual feedback is provided through CSS animations when the count changes
- All value operations are type-safe thanks to Stimulus's built-in type conversion

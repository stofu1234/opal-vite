# Opal + Vite + React.rb Example

This example demonstrates how to use **React.rb** with **Opal** and **Vite** to build interactive React applications using Ruby syntax.

## Features

- ✅ Write React components in Ruby using React.rb
- ✅ State management with `define_state`
- ✅ Event handling
- ✅ Component composition
- ✅ Fast HMR (Hot Module Replacement) with Vite
- ✅ Source maps for debugging

## Components

This example includes three interactive components:

1. **Counter** - Increment/decrement counter with state management
2. **Greeting** - Input field with controlled component pattern
3. **TodoList** - Full-featured todo app with add/remove/toggle functionality

## Setup

### Install Ruby Dependencies

```bash
bundle install
```

### Install JavaScript Dependencies

```bash
pnpm install
```

## Development

Start the development server with HMR:

```bash
pnpm dev
```

Open http://localhost:3001 in your browser.

## Production Build

Build for production:

```bash
pnpm build
```

Preview the production build:

```bash
pnpm preview
```

## Project Structure

```
react-app/
├── src/
│   ├── components/
│   │   ├── app.rb           # Main app component
│   │   ├── counter.rb       # Counter component
│   │   ├── greeting.rb      # Greeting component
│   │   └── todo_list.rb     # TodoList component
│   ├── main.rb              # Application entry point
│   ├── main_loader.js       # JavaScript loader
│   └── styles.rb            # CSS styles
├── index.html               # HTML template
├── vite.config.ts           # Vite configuration
├── package.json             # npm dependencies
└── Gemfile                  # Ruby dependencies
```

## Writing React Components in Ruby

### Basic Component

```ruby
require 'react'

class MyComponent
  include React::Component

  def render
    div class_name: 'my-component' do
      h1 'Hello from Ruby!'
      p 'This is a React component written in Ruby'
    end
  end
end
```

### Component with State

```ruby
class Counter
  include React::Component

  define_state :count, 0

  def render
    div do
      p "Count: #{state.count}"
      button on_click: method(:increment) do
        text 'Increment'
      end
    end
  end

  def increment(_event)
    set_state(count: state.count + 1)
  end
end
```

### Component with Props

```ruby
class Greeting
  include React::Component

  def render
    h1 "Hello, #{props.name}!"
  end
end

# Usage: Greeting(name: 'World')
```

## Key Concepts

### State Management

Use `define_state` to declare component state:

```ruby
define_state :count, 0        # Single state
define_state :name, ''        # String state
define_state :items, []       # Array state
```

Update state with `set_state`:

```ruby
set_state(count: state.count + 1)
set_state(name: 'New name', active: true)
```

### Event Handling

```ruby
# Method reference
button on_click: method(:handle_click) do
  text 'Click me'
end

# Lambda
button on_click: -> { puts 'Clicked!' } do
  text 'Click me'
end

# Inline block
button on_click: ->(e) { set_state(clicked: true) } do
  text 'Click me'
end
```

### Controlled Inputs

```ruby
input(
  type: 'text',
  value: state.input,
  on_change: method(:handle_change)
)

def handle_change(event)
  set_state(input: event.target.value)
end
```

## React.rb API

### Component Lifecycle (if needed)

```ruby
def component_did_mount
  # Called after component is mounted
end

def component_will_unmount
  # Called before component is unmounted
end

def component_did_update(prev_props, prev_state)
  # Called after state/props update
end
```

### Rendering Elements

```ruby
# HTML elements
div class_name: 'container' do
  h1 'Title'
  p 'Paragraph'
end

# With attributes
img src: '/image.png', alt: 'Description'

# Text content
span 'Text content'
text 'Plain text'
```

## Tips

1. **Use JavaScript loader**: Always import `.rb` files through a `.js` loader
2. **Check console**: Ruby `puts` statements appear in the browser console
3. **HMR**: Edit Ruby files and see instant updates
4. **Debugging**: Source maps allow debugging Ruby code in DevTools

## Learn More

- [React.rb Documentation](https://github.com/reactrb/reactrb)
- [Opal Documentation](https://opalrb.com/)
- [Vite Documentation](https://vitejs.dev/)

## Troubleshooting

### React.rb not found

Make sure `react-rb` gem is installed:

```bash
bundle install
```

### HMR not working

Ensure Vite dev server is running:

```bash
pnpm dev
```

### Compilation errors

Check Ruby syntax and ensure all `require` statements are correct.

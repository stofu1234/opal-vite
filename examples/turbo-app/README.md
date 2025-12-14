# Turbo + Opal + Vite Example

This example demonstrates how to control [Turbo (Hotwire)](https://turbo.hotwired.dev/) from Ruby using [Opal](https://opalrb.com/) with [opal-vite](https://github.com/stofu1234/opal-vite).

## Overview

Turbo is a JavaScript framework that enables fast, SPA-like experiences without writing much JavaScript. This example shows how to control all Turbo features directly from Ruby code using Stimulus controllers written in Ruby.

## Features Demonstrated

### 1. Turbo Drive 🚗
**Fast navigation without full page reloads**

- Programmatic navigation with `Turbo.visit()` from Ruby
- Different visit actions (advance, replace)
- Browser history management
- Turbo event handling

```ruby
def visit_page
  page = element.`getAttribute('data-page')`
  `window.Turbo.visit(#{page})`
end
```

### 2. Turbo Frames 🖼️
**Partial page updates with scoped navigation**

- Independent frame updates
- Lazy loading frames
- Frame targeting
- Dynamic content updates from Ruby

```ruby
def update_frame_content
  frame_id = element.`getAttribute('data-frame-id')`
  content = element.`getAttribute('data-content')`

  `
    const frame = document.getElementById(#{frame_id});
    if (frame) {
      frame.innerHTML = #{content};
    }
  `
end
```

### 3. Turbo Streams 📡
**Surgical DOM updates with 8 stream actions**

All 8 Turbo Stream actions controlled from Ruby:

| Action | Purpose | Demo |
|--------|---------|------|
| **append** | Add content to end of target | ✅ |
| **prepend** | Add content to beginning of target | ✅ |
| **replace** | Replace entire element | ✅ |
| **update** | Replace element content only | ✅ |
| **remove** | Delete element | ✅ |
| **before** | Insert before target | ✅ |
| **after** | Insert after target | ✅ |
| **refresh** | Trigger page refresh | ⚠️ (requires server) |

Example from Ruby:

```ruby
def append_item
  self.counter_value += 1
  item_html = "<div class='stream-item'>Item #{counter_value}</div>"

  `
    const stream = document.createElement('turbo-stream');
    stream.setAttribute('action', 'append');
    stream.setAttribute('target', 'stream-container');

    const template = document.createElement('template');
    template.innerHTML = #{item_html};
    stream.appendChild(template);

    document.body.appendChild(stream);
  `
end
```

## Technology Stack

- **Turbo 8.0+**: The speed of a single-page web application without having to write any JavaScript
- **Stimulus 3.2.2**: Modest JavaScript framework for HTML
- **opal_stimulus 0.2.0**: Ruby wrapper for Stimulus controllers
- **Opal 1.8**: Ruby to JavaScript compiler
- **Vite 5.0**: Next generation frontend tooling
- **opal-vite**: Integration layer between Opal and Vite

## Getting Started

### Prerequisites

- Ruby 3.x
- Node.js 18+ with pnpm
- Bundler 2.x

### Installation

```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies
pnpm install
```

### Development

```bash
# Start the development server
pnpm dev
```

Visit [http://localhost:3001](http://localhost:3001) to see the application.

### Production Build

```bash
# Build for production
pnpm build

# Preview production build
pnpm preview
```

## Project Structure

```
turbo-app/
├── app/
│   ├── javascript/
│   │   └── application.js          # Entry point (loads Turbo + Stimulus)
│   ├── opal/
│   │   ├── application.rb           # Opal entry point
│   │   └── controllers/
│   │       ├── turbo_navigation_controller.rb    # Turbo Drive demo
│   │       ├── turbo_frame_controller.rb         # Turbo Frames demo
│   │       └── turbo_stream_controller.rb        # Turbo Streams demo
│   ├── pages/
│   │   ├── page1.html               # Test page for navigation
│   │   └── page2.html               # Test page for navigation
│   └── styles.css
├── index.html
├── vite.config.ts
├── Gemfile
└── package.json
```

## How It Works

### 1. Global Exposure

The JavaScript entry point (`application.js`) exposes Turbo and Stimulus globally:

```javascript
import * as Turbo from "@hotwired/turbo"
import { Application, Controller } from "@hotwired/stimulus"

window.Turbo = Turbo
window.Controller = Controller
window.Stimulus = Application.start()
window.application = window.Stimulus
```

### 2. Ruby Controllers

Write Stimulus controllers in Ruby that call Turbo APIs:

```ruby
class TurboNavigationController < StimulusController
  def visit_page
    page = element.`getAttribute('data-page')`
    `window.Turbo.visit(#{page})`
  end
end
```

### 3. Automatic Registration

Controllers are automatically registered with Stimulus:

```ruby
StimulusController.register_all!
```

### 4. HTML Integration

Use standard Stimulus/Turbo HTML syntax:

```html
<button
  data-controller="turbo-navigation"
  data-action="click->turbo-navigation#visit_page"
  data-page="/about"
>
  Navigate
</button>
```

## Key Patterns

### Calling JavaScript from Ruby

Use backtick JavaScript to call Turbo APIs:

```ruby
# backtick_javascript: true

def my_action
  # Call JavaScript directly
  `window.Turbo.visit('/path')`

  # Access DOM elements
  element_id = `this.element.id`

  # Create and manipulate DOM
  `
    const el = document.createElement('div');
    el.textContent = 'Hello from Ruby!';
  `
end
```

### Creating Turbo Streams Dynamically

All stream actions follow the same pattern:

```ruby
def create_stream(action, target, content)
  `
    const stream = document.createElement('turbo-stream');
    stream.setAttribute('action', #{action});
    stream.setAttribute('target', #{target});

    const template = document.createElement('template');
    template.innerHTML = #{content};
    stream.appendChild(template);

    document.body.appendChild(stream);
  `
end
```

### Handling Turbo Events

Listen to Turbo events from Ruby:

```ruby
def connect
  # Listen to turbo:load event
  `
    document.addEventListener('turbo:load', () => {
      console.log('Page loaded via Turbo!');
    });
  `
end
```

## Benefits of Turbo + Ruby

✅ **Write once, run anywhere**: Same Ruby code controls frontend behavior
✅ **Full Turbo power**: All Turbo features available from Ruby
✅ **SPA-like UX**: Fast navigation and updates without full page reloads
✅ **Simplified stack**: Less context switching between Ruby and JavaScript
✅ **Hotwire philosophy**: HTML over the wire, minimal JavaScript
✅ **Progressive enhancement**: Works without JavaScript, better with it

## Limitations

⚠️ **Bundle size**: Includes Opal runtime (~100KB gzipped)
⚠️ **Server-side Turbo**: Examples are client-only; real apps need server integration
⚠️ **WebSocket/SSE**: Real-time Turbo Streams require backend
⚠️ **Learning curve**: Need to understand Turbo, Stimulus, and Opal

## Turbo Stream Actions Reference

### Append
Adds content to the **end** of a target element:
```ruby
`stream.setAttribute('action', 'append')`
```

### Prepend
Adds content to the **beginning** of a target element:
```ruby
`stream.setAttribute('action', 'prepend')`
```

### Replace
Replaces the **entire element** (including the wrapper):
```ruby
`stream.setAttribute('action', 'replace')`
```

### Update
Replaces **only the content** inside the element (preserves wrapper):
```ruby
`stream.setAttribute('action', 'update')`
```

### Remove
Deletes the element from the DOM:
```ruby
`stream.setAttribute('action', 'remove')`
```

### Before
Inserts content **immediately before** a target element:
```ruby
`stream.setAttribute('action', 'before')`
```

### After
Inserts content **immediately after** a target element:
```ruby
`stream.setAttribute('action', 'after')`
```

### Refresh
Triggers a page refresh (requires server-side implementation):
```ruby
`stream.setAttribute('action', 'refresh')`
```

## Next Steps

- Connect to a real backend (Rails, Sinatra, etc.)
- Implement WebSocket/SSE for real-time Turbo Streams
- Add form handling with Turbo
- Explore Turbo Native for mobile apps
- Implement custom Turbo Stream actions

## Resources

- [Turbo Handbook](https://turbo.hotwired.dev/handbook/introduction)
- [Turbo Drive Documentation](https://turbo.hotwired.dev/handbook/drive)
- [Turbo Frames Documentation](https://turbo.hotwired.dev/handbook/frames)
- [Turbo Streams Documentation](https://turbo.hotwired.dev/handbook/streams)
- [Stimulus Official Site](https://stimulus.hotwired.dev/)
- [Opal Ruby to JavaScript Compiler](https://opalrb.com/)
- [opal_stimulus Gem](https://github.com/josephschito/opal_stimulus)
- [opal-vite GitHub](https://github.com/stofu1234/opal-vite)

## License

MIT

# Stimulus + Opal + Vite Example

This example demonstrates how to write [Stimulus](https://stimulus.hotwired.dev/) controllers in Ruby using [Opal](https://opalrb.com/) and [opal-vite](https://github.com/stofu1234/opal-vite).

## Overview

Instead of writing JavaScript:
```javascript
// hello_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "output"]

  greet() {
    this.outputTarget.textContent = `Hello, ${this.nameTarget.value}!`
  }
}
```

Write Ruby:
```ruby
# hello_controller.rb
class HelloController < StimulusController
  self.targets = ["name", "output"]

  def greet
    output_target.text_content = "Hello, #{name_target.value}!"
  end
end
```

## Features Demonstrated

This example includes four controllers showcasing different Stimulus features:

### 1. Hello Controller
- **Features**: Basic targets and actions
- **Demonstrates**: Simple DOM manipulation with Ruby syntax

### 2. Counter Controller
- **Features**: Stimulus Values API with typed data
- **Demonstrates**: State management and value change callbacks

### 3. Clipboard Controller
- **Features**: CSS classes and browser APIs
- **Demonstrates**: Conditional styling and DOM queries

### 4. Slideshow Controller
- **Features**: Multiple targets and state transitions
- **Demonstrates**: Complex interactions with CSS classes

## Technology Stack

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

Visit [http://localhost:3000](http://localhost:3000) to see the application.

### Production Build

```bash
# Build for production
pnpm build

# Preview production build
pnpm preview
```

## Project Structure

```
stimulus-app/
├── app/
│   ├── javascript/
│   │   └── application.js          # Entry point
│   ├── opal/
│   │   ├── application.rb           # Opal entry point
│   │   └── controllers/
│   │       ├── hello_controller.rb
│   │       ├── counter_controller.rb
│   │       ├── clipboard_controller.rb
│   │       └── slideshow_controller.rb
│   └── styles.css
├── index.html
├── vite.config.ts
├── Gemfile
└── package.json
```

## How It Works

1. **Ruby Controllers**: Write Stimulus controllers in Ruby using `StimulusController` base class
2. **Opal Compilation**: Opal compiles Ruby to JavaScript
3. **Stimulus Registration**: Controllers are automatically registered with Stimulus
4. **Vite HMR**: Hot Module Replacement for instant feedback during development

## Stimulus Features in Ruby

### Targets

```ruby
class MyController < StimulusController
  self.targets = ["input", "output"]

  def process
    output_target.text_content = input_target.value
  end
end
```

### Values

```ruby
class MyController < StimulusController
  self.values = { count: :number, name: :string }

  def increment
    self.count_value += 1
  end

  def count_value_changed
    puts "Count changed to #{count_value}"
  end
end
```

### CSS Classes

```ruby
class MyController < StimulusController
  self.classes = ["active", "loading"]

  def toggle
    element.class_list.toggle(*active_classes)
  end
end
```

### Outlets

```ruby
class MyController < StimulusController
  self.outlets = ["other"]

  def notify
    other_outlet.do_something
  end
end
```

## Benefits of Ruby Controllers

✅ **Familiar Syntax**: Use Ruby's elegant syntax instead of JavaScript
✅ **Type Safety**: Ruby's type system and method checks
✅ **Code Reuse**: Share code between backend and frontend
✅ **Full Stimulus Features**: All Stimulus APIs available in Ruby
✅ **Opal Ecosystem**: Access to Opal gems and libraries

## Limitations

⚠️ **Bundle Size**: Includes Opal runtime (~100KB gzipped)
⚠️ **Debugging**: Source maps available, but Ruby stack traces
⚠️ **Ecosystem**: JavaScript Stimulus plugins require manual integration
⚠️ **Learning Curve**: Need to understand both Stimulus and Opal

## Next Steps

- Try modifying the controllers in `app/opal/controllers/`
- Add your own controller with `touch app/opal/controllers/my_controller.rb`
- Explore [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- Check out [Opal Documentation](https://opalrb.com/docs/)
- Learn about [opal_stimulus](https://github.com/josephschito/opal_stimulus)

## Resources

- [Stimulus Official Site](https://stimulus.hotwired.dev/)
- [Opal Ruby to JavaScript Compiler](https://opalrb.com/)
- [opal_stimulus Gem](https://github.com/josephschito/opal_stimulus)
- [Vite Documentation](https://vitejs.dev/)
- [opal-vite GitHub](https://github.com/stofu1234/opal-vite)

## License

MIT

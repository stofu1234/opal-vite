# Opal-Vite-Rails

Seamless integration of [Opal](https://opalrb.com/) (Ruby to JavaScript compiler) with [Vite](https://vitejs.dev/) in Rails applications. Write Ruby code that runs in the browser with the fast development experience of Vite.

## Features

- ✅ **Ruby in the Browser**: Write Ruby code that compiles to JavaScript
- ✅ **Vite Integration**: Fast HMR (Hot Module Replacement) during development
- ✅ **Rails Integration**: Seamless integration with Rails views and asset pipeline
- ✅ **Source Maps**: Debug Ruby code directly in browser DevTools
- ✅ **Production Ready**: Optimized builds with manifest-based asset resolution

## Requirements

- Ruby >= 3.0
- Rails >= 7.0
- Node.js >= 18.0
- Opal >= 1.8

## Installation

Add to your Gemfile:

```ruby
gem 'opal-vite-rails'
```

Install the gem:

```bash
bundle install
```

Run the generator:

```bash
rails generate opal_vite:install
```

This will:
- Create `app/opal/` directory for your Ruby code
- Generate `app/opal/application.rb` entry point
- Configure Vite with the Opal plugin
- Create an example controller and view
- Add necessary routes

Install JavaScript dependencies:

```bash
npm install vite-plugin-opal
# or
pnpm install vite-plugin-opal
```

## Usage

### Development Mode

Start the Vite development server in one terminal:

```bash
bin/vite dev
```

Start Rails in another terminal:

```bash
rails server
```

Visit `http://localhost:3000/opal_demo` to see Opal in action!

### Writing Opal Code

Create Ruby files in `app/opal/`:

```ruby
# app/opal/hello.rb
require 'native'

puts "Hello from Ruby running in the browser!"

# Use JavaScript via backticks
`
  document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM is ready!');

    const element = document.getElementById('my-element');
    if (element) {
      element.textContent = 'Updated by Ruby!';
    }
  });
`

# Or use the Native module for cleaner JS interop
class MyComponent
  def initialize(element_id)
    @element = Native(`document.getElementById(#{element_id})`)
  end

  def update(text)
    @element[:textContent] = text
  end
end

MyComponent.new('my-element').update('Hello from Ruby!')
```

### Using in Views

Add Opal JavaScript to your views with the helper:

```erb
<!-- app/views/welcome/index.html.erb -->
<div id="my-element">Loading...</div>

<%= opal_javascript_tag "hello" %>
```

The helper automatically handles development vs production modes:
- **Development**: Loads from Vite dev server with HMR
- **Production**: Loads precompiled assets from manifest

### View Helpers

#### `opal_javascript_tag`

Loads an Opal JavaScript bundle:

```erb
<%= opal_javascript_tag "application" %>
<%= opal_javascript_tag "application", defer: true %>
<%= opal_javascript_tag "application", type: "module" %>
```

#### `opal_asset_path`

Gets the path to an Opal asset:

```erb
<script src="<%= opal_asset_path('application.js') %>"></script>
```

#### `vite_running?`

Checks if Vite dev server is running:

```erb
<% if vite_running? %>
  <p>Development mode with HMR enabled</p>
<% else %>
  <p>Production mode</p>
<% end %>
```

### Requiring Other Files

Organize your code with `require`:

```ruby
# app/opal/lib/calculator.rb
class Calculator
  def add(a, b)
    a + b
  end
end

# app/opal/application.rb
require 'lib/calculator'

calc = Calculator.new
puts calc.add(5, 3) # => 8
```

### Production Deployment

Compile Opal assets:

```bash
rake opal_vite:compile
```

This runs Vite build and creates optimized bundles in `public/vite/`.

The compile task is automatically added to `rake assets:precompile`, so it runs during deployment on platforms like Heroku.

## Rake Tasks

```bash
# Compile Opal assets for production
rake opal_vite:compile

# Clean compiled assets
rake opal_vite:clean

# Show configuration info
rake opal_vite:info
```

## Configuration

Configure in `config/application.rb` or environment files:

```ruby
# config/application.rb
config.opal_vite.source_path = "app/opal"  # Default
config.opal_vite.public_output_path = "vite"  # Default
```

## Project Structure

```
app/
├── opal/
│   ├── application.rb          # Entry point
│   ├── application_loader.js   # JS loader (required for Vite)
│   └── lib/
│       └── my_module.rb        # Your Ruby modules
├── controllers/
└── views/

vite.config.ts                   # Vite config with opal plugin
```

## How It Works

1. **Development**:
   - Vite dev server watches `.rb` files
   - When a `.rb` file changes, Opal compiles it to JavaScript
   - HMR updates the browser instantly
   - Source maps allow debugging Ruby code in DevTools

2. **Production**:
   - `rake opal_vite:compile` builds optimized JavaScript bundles
   - Manifest file maps logical names to hashed filenames
   - Rails helpers load assets from the manifest

## Advanced Usage

### Custom Vite Configuration

Customize `vite.config.ts`:

```typescript
import { defineConfig } from 'vite'
import RubyPlugin from 'vite_ruby/plugins/ruby'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    opal({
      loadPaths: ['./app/opal', './lib/opal'],
      sourceMap: true,
      debug: process.env.NODE_ENV === 'development'
    })
  ],
  // Your custom Vite config...
})
```

### Using Opal Standard Library

Opal includes a standard library with Ruby core classes:

```ruby
require 'native'      # JavaScript interop
require 'promise'     # Promise support
require 'json'        # JSON parsing
require 'set'         # Set class
require 'ostruct'     # OpenStruct
# ... and more
```

## Troubleshooting

### HMR not working

Make sure:
1. Vite dev server is running (`bin/vite dev`)
2. You're using the JavaScript loader pattern (`.rb` files imported via `.js` loaders)
3. Rails is configured to proxy to Vite in development

### Assets not loading in production

Run the compile task before deployment:

```bash
RAILS_ENV=production rake opal_vite:compile
```

### Source maps not showing Ruby code

Ensure `sourceMap: true` in `vite.config.ts`:

```typescript
opal({
  sourceMap: true,
  // ...
})
```

## Examples

See the [examples/rails-app](../../examples/rails-app) directory for a complete working example.

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the MIT License.

## See Also

- [Opal](https://opalrb.com/) - Ruby to JavaScript compiler
- [Vite](https://vitejs.dev/) - Next generation frontend tooling
- [vite_ruby](https://vite-ruby.netlify.app/) - Vite integration for Ruby
- [vite-plugin-opal](../../packages/vite-plugin-opal) - Vite plugin for Opal

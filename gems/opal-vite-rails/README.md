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

This will (paths assume vite_ruby's default `sourceCodeDir` of `app/frontend`;
the generator reads `config/vite.json`):
- Generate `app/frontend/opal/application.rb`, the Ruby entry point
- Generate `app/frontend/entrypoints/opal.js`, the Vite entrypoint that imports it
- Configure Vite with the Opal plugin
- Create an example controller and view (`/opal_demo`)
- Add necessary routes

The engine tells Zeitwerk to ignore the Opal source directories
(`config.opal_vite.source_path`, default `app/opal`, and `<sourceCodeDir>/opal`),
so the browser-side Ruby is never loaded by the server.

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

Create Ruby files in `app/frontend/opal/` and import them from an entrypoint
in `app/frontend/entrypoints/`:

```js
// app/frontend/entrypoints/hello.js
import '../opal/hello.rb'
```

```ruby
# app/frontend/opal/hello.rb
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

`opal_javascript_tag "hello"` is `vite_javascript_tag "hello.js"`, so it
emits `type="module"` and switches between the Vite dev server and the build
manifest the same way.

The Opal runtime is imported by the compiled Ruby itself; you don't need a
separate tag or `import '/@opal-runtime'` for it.

### View Helpers

#### `opal_javascript_tag`

Loads an Opal JavaScript bundle:

```erb
<%= opal_javascript_tag "application" %>
<%= opal_javascript_tag "application", defer: true %>
```

#### `opal_runtime_tag` (deprecated)

Outputs nothing. The runtime is loaded by the compiled `.rb` modules.

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
# app/frontend/opal/lib/calculator.rb
class Calculator
  def add(a, b)
    a + b
  end
end

# app/frontend/opal/application.rb
require 'lib/calculator'

calc = Calculator.new
puts calc.add(5, 3) # => 8
```

### Production Deployment

Compile Opal assets:

```bash
rake opal_vite:compile
```

This runs the Vite build (through vite_ruby, like `rake vite:build`) and creates optimized bundles in `public/vite/`.

You usually don't need to run it yourself: vite_rails already runs the Vite build, which compiles the Opal sources, as part of `rake assets:precompile`, so deployment on platforms like Heroku works without an extra step.

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
├── frontend/                   # vite_ruby sourceCodeDir
│   ├── entrypoints/
│   │   ├── application.js      # Created by `vite install`
│   │   └── opal.js             # Imports ../opal/application.rb
│   └── opal/
│       ├── application.rb      # Ruby entry point
│       └── lib/
│           └── my_module.rb    # Your Ruby modules
├── controllers/
└── views/

vite.config.ts                  # Vite config with the opal plugin
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
import RubyPlugin from 'vite-plugin-ruby'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    opal({
      loadPaths: ['./app/frontend/opal', './lib/opal'],
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
2. The `.rb` file is imported from a file in `entrypoints/` (directly or via other imports)
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

## Version Compatibility

The npm plugin runs the gem's Ruby code, so keep the two in step:

| vite-plugin-opal (npm) | opal-vite (gem) | opal-vite-rails (gem) | Notes |
|------------------------|-----------------|-----------------------|-------|
| >= 0.3.19 | >= 0.3.18 | >= 0.3.14 | `loadPaths` / `arityCheck` / `freezing` are applied when compiling |
| >= 0.3.16 | >= 0.3.15 | >= 0.3.14 | Shared runtime: corelib is loaded once |
| >= 0.3.16 | 0.3.12 – 0.3.14 | — | Works; each `.rb` bundle carries its own corelib (warning at startup) |
| >= 0.3.16 | < 0.3.12 | — | Works without the `stubs` option (using it fails with a clear error) |

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

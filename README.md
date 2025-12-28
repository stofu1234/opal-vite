# opal-vite

Integrate [Opal](https://opalrb.com/) with [Vite](https://vitejs.dev/) - Write Ruby code and run it in the browser with Vite's lightning-fast development experience.

## Features

- ⚡️ **Fast Development**: Leverage Vite's instant server start and HMR
- 💎 **Ruby in Browser**: Write Ruby code that compiles to JavaScript via Opal
- 🔥 **Hot Module Replacement**: See changes instantly without page reload
- 🗺️ **Source Maps**: Debug your Ruby code in the browser DevTools
- 📦 **Auto Runtime Loading**: Opal runtime loads automatically
- 🚂 **Rails Integration**: Seamlessly integrate with Rails applications

## Project Structure

This is a monorepo containing:

- **packages/vite-plugin-opal**: Vite plugin for Opal compilation
- **gems/opal-vite**: Ruby gem for Opal-Vite integration
- **gems/opal-vite-rails**: Rails integration gem
- **examples/standalone**: Standalone SPA example
- **examples/stimulus-app**: Stimulus + Opal integration example
- **examples/turbo-app**: Turbo + Opal integration example
- **examples/practical-app**: Full-featured Todo app with real-world patterns
- **examples/rails-app**: Rails integration example (coming soon)

## Quick Start

### Try the Practical App Example (Recommended)

The fastest way to see Opal + Vite in action:

```bash
# Clone the repository
git clone https://github.com/your-org/opal-vite.git
cd opal-vite

# Install root dependencies
pnpm install

# Navigate to practical-app example
cd examples/practical-app

# Install dependencies
bundle install
pnpm install

# Run development server
pnpm dev
```

Open `http://localhost:3002` to see a full-featured Todo app built with Ruby!

### Standalone Project

```bash
# Install dependencies
pnpm install
cd examples/standalone
pnpm install

# Run development server
pnpm dev
```

### Rails Project (Coming Soon)

```bash
# Add to Gemfile
gem 'opal-vite-rails'

# Install
bundle install
bundle exec rails generate opal_vite:install

# Start servers
bin/vite dev  # In one terminal
rails server  # In another terminal
```

## Usage

### vite.config.ts

```typescript
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      loadPaths: ['./src'],
      sourceMap: true
    })
  ]
})
```

### Ruby Code (src/main.rb)

```ruby
puts "Hello from Ruby!"

class Greeter
  def initialize(name)
    @name = name
  end

  def greet
    puts "Hello, #{@name}!"
  end
end

greeter = Greeter.new("World")
greeter.greet
```

### HTML

```html
<!DOCTYPE html>
<html>
<head>
  <title>Opal + Vite</title>
</head>
<body>
  <h1>Opal + Vite</h1>
  <script type="module" src="/src/main.rb"></script>
</body>
</html>
```

## Documentation

### Packages

- **[vite-plugin-opal](./packages/vite-plugin-opal)** - Vite plugin for compiling Ruby files
  - Plugin configuration options
  - API reference
  - Advanced usage examples

- **[opal-vite](./gems/opal-vite)** - Core Ruby gem
  - Compiler API
  - Configuration
  - CLI commands

- **[opal-vite-rails](./gems/opal-vite-rails)** - Rails integration
  - Installation guide
  - View helpers
  - Rake tasks
  - Production deployment

### Examples

Explore our examples to learn different integration patterns:

| Example | Description | Tech Stack | Features | Port |
|---------|-------------|------------|----------|------|
| **[standalone](./examples/standalone)** | Basic Vite + Opal setup | Opal + Vite | Simple compilation, Multi-file deps, HMR | 3000 |
| **[stimulus-app](./examples/stimulus-app)** | Stimulus integration | Opal + Stimulus + Vite | Stimulus controllers in Ruby, Counter demo | 3001 |
| **[turbo-app](./examples/turbo-app)** | Turbo integration | Opal + Turbo + Vite | Turbo Frames, Turbo Streams in Ruby | 3002 |
| **[practical-app](./examples/practical-app)** | Real-world Todo app | Opal + Stimulus + Vite | CRUD, LocalStorage, Modals, Toasts, Animations | 3002 |
| **[rails-app](./examples/rails-app)** | Rails integration | Rails + Opal + Vite | View helpers, Asset pipeline | 3000 |

#### Standalone Example
Basic Vite + Opal setup demonstrating:
- Simple compilation
- Multi-file dependencies
- HMR demonstrations

#### Stimulus App Example
Integration with [Stimulus](https://stimulus.hotwired.dev/) framework:
- Write Stimulus controllers in Ruby using `opal_stimulus` gem
- Counter application with increment/decrement
- Shows Ruby → JavaScript controller compilation

#### Turbo App Example
Integration with [Turbo](https://turbo.hotwired.dev/) for dynamic updates:
- Turbo Frames for partial page updates
- Turbo Streams for real-time updates
- Counter with server-less dynamic updates
- All in Ruby without writing JavaScript

#### Practical App Example ⭐ **Recommended**
Full-featured Todo application demonstrating real-world patterns:
- **CRUD Operations**: Create, read, update, delete todos
- **LocalStorage**: Data persistence across page reloads
- **Form Validation**: Real-time validation with visual feedback
- **Modal Dialogs**: Edit todos in animated modal
- **Toast Notifications**: Success/error messages
- **Animations**: Smooth transitions throughout
- **Cross-controller Communication**: CustomEvent pattern
- **Template Cloning**: Dynamic content generation

[→ View detailed documentation](./examples/practical-app/README.md)

#### Rails App Example (Coming Soon)
Full Rails integration:
- Rails setup
- View integration
- Production build

## How It Works

1. **Development Mode**:
   - Vite dev server watches `.rb` files
   - When imported, the plugin calls Ruby compiler via `child_process`
   - Compiled JavaScript is returned with source maps
   - HMR updates browser when Ruby files change

2. **Production Mode**:
   - `vite build` compiles all `.rb` files to optimized JavaScript
   - Source maps can be generated for debugging
   - Assets are fingerprinted and added to manifest

3. **Rails Integration**:
   - Development: Proxies to Vite dev server for HMR
   - Production: Loads precompiled assets from manifest
   - View helpers automatically handle both modes

## Key Concepts

### JavaScript Loaders

Due to Vite's module resolution, `.rb` files cannot be directly imported in HTML. Instead, use a JavaScript loader:

```javascript
// main_loader.js
import './main.rb'
```

```html
<script type="module" src="/src/main_loader.js"></script>
```

### Opal Runtime

The Opal runtime is automatically injected via a virtual module `/@opal-runtime`. This provides Ruby core classes and standard library.

### Load Paths

Configure load paths to resolve `require` statements:

```typescript
opal({
  loadPaths: ['./app/opal', './lib/opal']
})
```

Files in these directories can be required without specifying the full path.

## Troubleshooting

### HMR Not Working

- Ensure Vite dev server is running
- Check that you're using JavaScript loaders for `.rb` files
- Verify the plugin is in `vite.config.ts`

### Compilation Errors

- Check Ruby syntax with `ruby -c file.rb`
- Verify all required files are in load paths
- Some Ruby features are not supported by Opal (see [Opal docs](https://opalrb.com/docs/))

### Performance Issues

- Enable caching in development (automatic)
- For large projects, consider splitting into smaller modules
- Use `debug: false` in production

## Development

```bash
# Install dependencies
pnpm install

# Build all packages
pnpm build

# Run tests
cd packages/vite-plugin-opal
pnpm test

cd ../../gems/opal-vite
bundle exec rspec

# Run examples
cd examples/standalone
pnpm dev

cd ../rails-app
bin/vite dev
rails server

# Clean build artifacts
pnpm clean
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## Roadmap

- [x] Support for more Opal standard library features (v0.3.1: URIHelpers, Base64Helpers)
- [ ] Better error messages and debugging
- [ ] Performance optimizations
- [ ] Additional Rails integrations (ActionCable, etc.)
- [ ] VS Code extension for `.rb` file support
- [ ] CDN support for Opal runtime

## License

MIT

## Credits

- [Opal](https://opalrb.com/) - Ruby to JavaScript compiler
- [Vite](https://vitejs.dev/) - Next generation frontend tooling
- [vite_ruby](https://github.com/ElMassimo/vite_ruby) - Inspiration for Rails integration

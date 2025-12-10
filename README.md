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
- **examples/rails-app**: Rails integration example

## Quick Start

### Standalone Project

```bash
# Install dependencies
pnpm install
cd examples/standalone
pnpm install

# Run development server
pnpm dev
```

### Rails Project

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

- **[Standalone Example](./examples/standalone)** - Basic Vite + Opal setup
  - Simple compilation
  - Multi-file dependencies
  - HMR demonstrations

- **[Rails Example](./examples/rails-app)** - Full Rails integration
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

- [ ] Support for more Opal standard library features
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

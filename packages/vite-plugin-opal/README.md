# vite-plugin-opal

Vite plugin for compiling Ruby files using [Opal](https://opalrb.com/). Write Ruby code and run it in the browser with Vite's fast development experience.

## Features

- ⚡️ **Fast Compilation**: Compile `.rb` files on-demand during development
- 🔥 **Hot Module Replacement**: Instant updates when Ruby code changes
- 🗺️ **Source Maps**: Debug Ruby code in browser DevTools
- 📦 **Automatic Runtime**: Opal runtime is injected automatically
- 🔍 **Dependency Tracking**: Handles `require` statements and tracks dependencies
- 💾 **Smart Caching**: Caches compilation results based on file modification time

## Installation

```bash
npm install vite-plugin-opal
# or
pnpm add vite-plugin-opal
# or
yarn add vite-plugin-opal
```

You also need to have Ruby and the `opal-vite` gem installed:

```bash
gem install opal-vite
# or add to Gemfile
gem 'opal-vite'
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
      sourceMap: true,
      debug: false
    })
  ]
})
```

### Ruby Code (src/main.rb)

```ruby
puts "Hello from Ruby!"

class Counter
  def initialize
    @count = 0
  end

  def increment
    @count += 1
    puts "Count: #{@count}"
  end
end

counter = Counter.new
counter.increment
counter.increment
```

### JavaScript Loader (src/main_loader.js)

**Important**: Due to Vite's module resolution, you cannot directly import `.rb` files in HTML. Use a JavaScript loader:

```javascript
// src/main_loader.js
import './main.rb'
```

### HTML (index.html)

```html
<!DOCTYPE html>
<html>
<head>
  <title>Opal + Vite</title>
</head>
<body>
  <h1>Opal + Vite</h1>
  <script type="module" src="/src/main_loader.js"></script>
</body>
</html>
```

## Options

### `gemPath`

- Type: `string`
- Default: `'opal-vite'`

Path to the `opal-vite` gem. Use a relative or absolute path for local development.

### `sourceMap`

- Type: `boolean`
- Default: `true`

Enable source map generation for debugging.

### `loadPaths`

- Type: `string[]`
- Default: `['./src']`

Directories to search for Ruby files when using `require`.

### `arityCheck`

- Type: `boolean`
- Default: `false`

Enable arity checking in compiled code.

### `freezing`

- Type: `boolean`
- Default: `true`

Enable object freezing for immutability.

### `debug`

- Type: `boolean`
- Default: `false`

Enable debug logging.

## How It Works

### Development Mode

1. Vite dev server starts and loads the plugin
2. When a `.rb` file is imported, the plugin's `load` hook is triggered
3. Plugin spawns a Ruby child process to compile the file using Opal
4. Compiled JavaScript is returned with source maps
5. HMR watches for file changes and invalidates the module
6. Browser receives update and hot-reloads the module

### Production Mode

1. `vite build` processes all entry points
2. Ruby files are compiled to optimized JavaScript
3. Source maps can optionally be generated
4. Assets are fingerprinted and added to manifest

## Advanced Usage

### Requiring Other Files

```ruby
# src/lib/helper.rb
module Helper
  def self.greet(name)
    "Hello, #{name}!"
  end
end

# src/app.rb
require 'lib/helper'

puts Helper.greet("World")
```

### Using Native JavaScript

```ruby
require 'native'

# Access DOM
element = Native(`document.getElementById('app')`)
element[:textContent] = 'Updated by Ruby!'

# Use JavaScript libraries
`console.log('From Ruby!')`
```

### Multi-file Dependencies

The plugin automatically tracks dependencies and ensures proper load order:

```ruby
# lib/calculator.rb
class Calculator
  def add(a, b); a + b; end
end

# lib/formatter.rb
require 'lib/calculator'

class Formatter
  def format_sum(a, b)
    calc = Calculator.new
    "#{a} + #{b} = #{calc.add(a, b)}"
  end
end

# app.rb
require 'lib/formatter'
puts Formatter.new.format_sum(5, 3)
```

## Troubleshooting

### Ruby not found

Ensure Ruby is in your PATH:

```bash
which ruby
ruby --version
```

### Opal gem not found

Install the opal-vite gem:

```bash
gem install opal-vite
```

### HMR not working

- Ensure Vite dev server is running
- Use JavaScript loaders for `.rb` files
- Check browser console for errors

### Compilation errors

- Check Ruby syntax with `ruby -c yourfile.rb`
- Verify all required files are in load paths
- Some Ruby features are not supported by Opal

## Related Projects

- [opal-vite](../../gems/opal-vite) - Core Ruby gem
- [opal-vite-rails](../../gems/opal-vite-rails) - Rails integration
- [Opal](https://opalrb.com/) - Ruby to JavaScript compiler

## License

MIT

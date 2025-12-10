# opal-vite

Core Ruby gem for integrating [Opal](https://opalrb.com/) (Ruby to JavaScript compiler) with [Vite](https://vitejs.dev/). This gem provides the compilation backend for the `vite-plugin-opal` package.

## Features

- 🔨 **Ruby Compilation**: Compiles Ruby code to JavaScript using Opal
- 📊 **Dependency Tracking**: Tracks `require` statements and dependencies
- 🗺️ **Source Maps**: Generates source maps for debugging
- ⚙️ **Configuration**: Flexible configuration options
- 🔧 **CLI**: Command-line interface for standalone compilation
- 🔌 **JSON API**: JSON-based API for Node.js integration

## Installation

Add to your Gemfile:

```ruby
gem 'opal-vite'
```

Then run:

```bash
bundle install
```

## Requirements

- Ruby >= 3.0
- Opal >= 1.8

## Usage

### As a Library

```ruby
require 'opal-vite'

# Create a compiler instance
compiler = Opal::Vite::Compiler.new

# Compile Ruby code
source = <<~RUBY
  class Greeter
    def greet(name)
      "Hello, #{name}!"
    end
  end

  greeter = Greeter.new
  puts greeter.greet("World")
RUBY

result = compiler.compile(source, 'greeter.rb')

# Access compiled code
puts result[:code]         # JavaScript output
puts result[:map]          # Source map (JSON string)
puts result[:dependencies] # Array of required files
```

### CLI Commands

#### Compile a File

```bash
opal-vite compile app.rb
```

#### Compile to File

```bash
opal-vite compile app.rb -o app.js
```

#### Generate Source Map

```bash
opal-vite compile app.rb -o app.js -m
```

#### Verbose Output

```bash
opal-vite compile app.rb -v
```

#### Show Version

```bash
opal-vite version
```

#### Show Help

```bash
opal-vite help
```

## API Reference

### `Opal::Vite::Compiler`

Main compiler class for converting Ruby to JavaScript.

#### `#compile(source, file_path)`

Compiles Ruby source code to JavaScript.

**Parameters:**
- `source` (String): Ruby source code
- `file_path` (String): Path to the source file

**Returns:**
- Hash with `:code`, `:map`, and `:dependencies` keys

#### `.runtime_code`

Returns the Opal runtime JavaScript code.

### `Opal::Vite::Config`

Configuration class with attributes:
- `load_paths` (Array<String>)
- `source_map_enabled` (Boolean)
- `debug` (Boolean)

## Integration with Vite

This gem works with [vite-plugin-opal](../../packages/vite-plugin-opal).

The Vite plugin spawns Ruby processes and uses this gem to compile `.rb` files.

## Examples

### Simple Compilation

```ruby
require 'opal-vite'

compiler = Opal::Vite::Compiler.new
result = compiler.compile('puts "Hello, World!"', 'hello.rb')
puts result[:code]
```

### CLI Usage

```bash
# Simple compilation
opal-vite compile app.rb > app.js

# With source map
opal-vite compile app.rb -o app.js -m

# Verbose mode
opal-vite compile app.rb -v
```

## Development

### Running Tests

```bash
bundle install
bundle exec rspec
```

## Related Projects

- [vite-plugin-opal](../../packages/vite-plugin-opal) - Vite plugin
- [opal-vite-rails](../opal-vite-rails) - Rails integration
- [Opal](https://opalrb.com/) - Ruby to JavaScript compiler

## License

MIT

# Installation

This guide covers the installation process for opal-vite in different scenarios.

## Requirements

| Requirement | Version |
|-------------|---------|
| Node.js | 18+ |
| Ruby | 3.0+ |
| pnpm / npm | Latest |

## Install Packages

### 1. Vite Plugin (npm)

```bash
# Using pnpm (recommended)
pnpm add -D vite-plugin-opal

# Using npm
npm install -D vite-plugin-opal
```

### 2. Ruby Gem

```bash
# Direct install
gem install opal opal-vite

# Or add to Gemfile
bundle add opal opal-vite
```

### Gemfile

```ruby
source 'https://rubygems.org'

gem 'opal', '~> 1.8'
gem 'opal-vite', '~> 0.2'
```

Then run:

```bash
bundle install
```

## Configuration

### vite.config.ts

```typescript
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      // Ruby source directories
      loadPaths: ['./app/opal'],

      // Enable source maps for debugging
      sourceMap: true,

      // Enable debug output (optional)
      debug: false
    })
  ]
})
```

### Plugin Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `loadPaths` | `string[]` | `['./app/opal']` | Directories containing Ruby source files |
| `sourceMap` | `boolean` | `true` | Generate source maps for debugging |
| `debug` | `boolean` | `false` | Enable debug output |
| `compilerOptions` | `object` | `{}` | Additional Opal compiler options |
| `cdn` | `'unpkg' \| 'jsdelivr' \| 'cdnjs' \| string` | `false` | Load Opal runtime from CDN |
| `opalVersion` | `string` | `'1.8.2'` | Opal version when using CDN |

See [CDN Guide](/guide/cdn) for details on CDN configuration.

## Project Setup

### 1. Create Directory Structure

```bash
mkdir -p app/opal/controllers
```

### 2. Create Entry Point

```ruby
# app/opal/application.rb
require 'opal'

puts "opal-vite is working!"
```

### 3. Create JavaScript Loader

```javascript
// src/main.js
import './app/opal/application.rb'
```

### 4. Update index.html

```html
<!DOCTYPE html>
<html>
<head>
  <title>My Opal App</title>
</head>
<body>
  <script type="module" src="/src/main.js"></script>
</body>
</html>
```

### 5. Start Development Server

```bash
pnpm dev
```

## Using with Bundler

If you have a Gemfile, the plugin automatically uses `bundle exec` to run the compiler:

```bash
# Automatically detected
bundle exec ruby -r opal/vite/compiler ...
```

## Verify Installation

After starting the dev server, open the browser console. You should see:

```
opal-vite is working!
```

## Next Steps

- [Getting Started](/guide/getting-started) - Build your first app
- [Stimulus Controller Pattern](/guide/stimulus-controller-pattern) - Write controllers in Ruby
- [API Reference](/api/v1/) - Explore OpalVite Helpers

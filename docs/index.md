---
layout: home

hero:
  name: opal-vite
  text: Ruby in the Browser with Vite
  tagline: Write Ruby code and run it in the browser with Vite's lightning-fast development experience
  image:
    src: /hero.png
    alt: opal-vite logo
  actions:
    - theme: brand
      text: Get Started
      link: /guide/getting-started
    - theme: alt
      text: View on GitHub
      link: https://github.com/stofu1234/opal-vite

features:
  - icon: ⚡️
    title: Fast Development
    details: Leverage Vite's instant server start and Hot Module Replacement for a seamless development experience.
  - icon: 💎
    title: Ruby in Browser
    details: Write Ruby code that compiles to JavaScript via Opal. Use familiar Ruby syntax and patterns.
  - icon: 🔥
    title: Hot Module Replacement
    details: See changes instantly without page reload. Edit your Ruby code and watch it update in real-time.
  - icon: 🗺️
    title: Source Maps
    details: Debug your Ruby code directly in the browser DevTools with full source map support.
  - icon: 📦
    title: Auto Runtime Loading
    details: Opal runtime loads automatically. No manual configuration required.
  - icon: 🎯
    title: Stimulus Integration
    details: Write Stimulus controllers in Ruby with OpalVite Helpers for DOM manipulation and more.
  - icon: 🛠️
    title: Editor Plugins
    details: LSP support for VS Code, IntelliJ IDEA, and Vim/Neovim with diagnostics and code snippets.
---

## Quick Installation

### npm / pnpm

```bash
# Install the Vite plugin
pnpm add -D vite-plugin-opal

# Install the Ruby gem
gem install opal-vite
```

### Gemfile

```ruby
gem 'opal'
gem 'opal-vite'
```

## Basic Setup

### vite.config.ts

```typescript
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      loadPaths: ['./app/opal'],
      sourceMap: true
    })
  ]
})
```

### Your First Ruby File

```ruby
# app/opal/application.rb
puts "Hello from Ruby!"

class Greeter
  def initialize(name)
    @name = name
  end

  def greet
    puts "Hello, #{@name}!"
  end
end

Greeter.new("World").greet
```

## Playground

Try opal-vite with live demo applications:

- [Practical App](https://stofu1234.github.io/opal-vite/playground/practical-app/) - Full-featured Todo app
- [Chart App](https://stofu1234.github.io/opal-vite/playground/chart-app/) - Chart visualization
- [Stimulus App](https://stofu1234.github.io/opal-vite/playground/stimulus-app/) - Stimulus controller basics
- [API Example](https://stofu1234.github.io/opal-vite/playground/api-example/) - API integration patterns
- [Form Validation](https://stofu1234.github.io/opal-vite/playground/form-validation-app/) - Real-time validation
- [i18n App](https://stofu1234.github.io/opal-vite/playground/i18n-app/) - Internationalization
- [PWA App](https://stofu1234.github.io/opal-vite/playground/pwa-app/) - Offline support
- [Vue App](https://stofu1234.github.io/opal-vite/playground/vue-app/) - Vue.js integration
- [React App](https://stofu1234.github.io/opal-vite/playground/react-app/) - React integration

See all demos on the [Playground](/playground) page.

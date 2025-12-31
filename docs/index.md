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

## Developer Tools

<div style="display: flex; align-items: center; gap: 20px; margin: 20px 0; padding: 20px; background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%); border-radius: 12px;">
  <img src="/opal-devtools-icon.png" alt="Opal DevTools" style="width: 80px; height: 80px; border-radius: 12px;" />
  <div>
    <h3 style="margin: 0 0 8px 0; color: #fff;">Opal DevTools</h3>
    <p style="margin: 0 0 12px 0; color: #ccc;">Supercharge your Opal development with browser DevTools integration. Inspect Ruby objects, debug compiled code, and accelerate your workflow.</p>
    <div style="display: flex; gap: 12px; flex-wrap: wrap;">
      <a href="https://chromewebstore.google.com/detail/opal-devtools/bfhlgblnmbaecglnakfajahfblnjaebo" target="_blank" style="display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; background: #4285f4; color: white; border-radius: 6px; text-decoration: none; font-weight: 500;">
        <span>Chrome</span>
      </a>
      <span style="display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; background: #444; color: #999; border-radius: 6px; font-weight: 500;">
        Firefox (Coming Soon)
      </span>
      <span style="display: inline-flex; align-items: center; gap: 6px; padding: 8px 16px; background: #444; color: #999; border-radius: 6px; font-weight: 500;">
        Edge (Coming Soon)
      </span>
    </div>
  </div>
</div>

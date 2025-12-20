# Troubleshooting Guide

This guide helps you diagnose and fix common issues when working with Opal-Vite.

## Table of Contents

- [Common Errors](#common-errors)
- [Controller Issues](#controller-issues)
- [Compilation Issues](#compilation-issues)
- [Runtime Errors](#runtime-errors)
- [Build & Deployment Issues](#build--deployment-issues)
- [Performance Issues](#performance-issues)
- [Debugging Techniques](#debugging-techniques)

## Common Errors

### Error: "function is not defined"

**Symptom:**
```
TypeError: ctrl.myFunction is not a function
```

**Cause:** Function is called before it's defined in backtick JavaScript.

**Solution:** Define all helper functions BEFORE they are used:

```ruby
# ❌ BAD
def connect
  `
    doSomething();  # Called before definition

    function doSomething() {
      // ...
    }
  `
end

# ✅ GOOD
def connect
  `
    function doSomething() {
      // ...
    }

    doSomething();  # Called after definition
  `
end
```

**Example from chart-app fix:**
```ruby
def connect
  `
    const ctrl = this;

    // Define functions FIRST
    ctrl.getDefaultData = function(type) { /* ... */ };
    ctrl.getDefaultOptions = function(type) { /* ... */ };

    // THEN use them
    const data = ctrl.getDefaultData('line');
    const options = ctrl.getDefaultOptions('line');
  `
end
```

### Error: "Missing target element"

**Symptom:**
```
Error: Missing target element "canvas" for "chart" controller
```

**Cause:** Controller is instantiated multiple times or on elements without the target.

**Solution:** Ensure `data-controller` is on a parent element that contains all targets:

```html
<!-- ❌ BAD: Controller on each button -->
<canvas data-controller="chart" data-chart-target="canvas"></canvas>
<button data-controller="chart" data-action="click->chart#update">Update</button>

<!-- ✅ GOOD: Controller on parent -->
<div data-controller="chart">
  <canvas data-chart-target="canvas"></canvas>
  <button data-action="click->chart#update">Update</button>
</div>
```

### Error: "Controller not found"

**Symptom:**
```
Stimulus: No controller found for identifier "my-controller"
```

**Cause:** Controller not registered or naming mismatch.

**Solutions:**

1. **Check registration:**
```ruby
# application.rb
require 'controllers/my_controller'
StimulusController.register_all!
```

2. **Check naming convention:**
```ruby
# File: my_controller.rb
class MyController < StimulusController  # → my (not my_controller)

# HTML
<div data-controller="my">  # NOT my-controller or my_controller
```

3. **Verify inheritance:**
```ruby
# ❌ BAD: Don't inherit from other custom controllers
class DataChartController < ChartController  # Won't register!

# ✅ GOOD: Inherit from StimulusController
class ChartController < StimulusController  # Will register!
```

### Error: "backtick_javascript required"

**Symptom:**
```
Opal compilation error: backtick_javascript is required
```

**Cause:** Inline JavaScript used without enabling backtick mode.

**Solution:** Add pragma at top of file:

```ruby
# backtick_javascript: true

class MyController < StimulusController
  def connect
    `console.log('This works now!')`
  end
end
```

### Error: "Cannot find module"

**Symptom:**
```
Error: Cannot find module './my_file'
Error loading: LoadError: cannot load such file -- my_file
```

**Solutions:**

1. **Check file path:**
```ruby
# File structure:
# app/opal/
#   application.rb
#   utils/
#     helper.rb

# ✅ CORRECT
require 'utils/helper'

# ❌ WRONG
require './utils/helper'
require 'helper'
```

2. **Add explicit load path:**
```typescript
// vite.config.ts
export default defineConfig({
  plugins: [
    opal({
      additionalLoadPaths: [
        './app/lib',
        './vendor/opal'
      ]
    })
  ]
});
```

3. **Check for typos:**
```ruby
# File: counter_controller.rb
require 'controllers/counter_controller'  # ❌ Can't require itself!
require 'controllers/other_controller'    # ✅ OK
```

## Controller Issues

### Controllers Not Connecting

**Symptom:** `connect()` method never called, no console output.

**Debugging steps:**

1. **Check Stimulus is loaded:**
```javascript
// In browser console
console.log(window.Stimulus || window.application);
```

2. **Check controller is registered:**
```javascript
// In browser console
const app = window.Stimulus || window.application;
console.log(app.router.modules);
```

3. **Check HTML attributes:**
```html
<!-- All required attributes present? -->
<div data-controller="my">  <!-- controller name -->
  <div data-my-target="element">  <!-- target -->
    <button data-action="click->my#doSomething">  <!-- action -->
```

4. **Check console for errors:**
   - Open DevTools (F12)
   - Look for JavaScript/Opal errors
   - Check Network tab for failed requests

### Multiple Controller Instances

**Symptom:** Controller connects multiple times, state gets confused.

**Cause:** `data-controller` attribute on multiple elements.

**Solution:**

```html
<!-- ❌ BAD: Creates 4 instances! -->
<div>
  <button data-controller="chart" data-action="click->chart#update">
  <button data-controller="chart" data-action="click->chart#add">
  <button data-controller="chart" data-action="click->chart#remove">
  <canvas data-controller="chart" data-chart-target="canvas">
</div>

<!-- ✅ GOOD: Creates 1 instance -->
<div data-controller="chart">
  <button data-action="click->chart#update">
  <button data-action="click->chart#add">
  <button data-action="click->chart#remove">
  <canvas data-chart-target="canvas">
</div>
```

### Values Not Updating

**Symptom:** Stimulus values don't trigger callbacks.

**Solutions:**

1. **Define value types:**
```ruby
class MyController < StimulusController
  self.values = { count: :number }  # Required!
end
```

2. **Use correct value access:**
```ruby
# ❌ BAD
`this.count = 5`  # Doesn't trigger callback

# ✅ GOOD
`this.countValue = 5`  # Triggers countValueChanged
```

3. **Implement callback:**
```ruby
def count_value_changed
  `console.log('Count changed to:', this.countValue)`
end
```

## Compilation Issues

### Opal Compilation Fails

**Symptom:**
```
Failed to compile Opal: SyntaxError
```

**Common causes:**

1. **Ruby syntax error:**
```ruby
# ❌ BAD
def my_method
  puts "Missing end keyword"

# ✅ GOOD
def my_method
  puts "Has end keyword"
end
```

2. **Unsupported Ruby feature:**
```ruby
# ❌ BAD: Some Ruby features not supported in Opal
File.read('file.txt')  # File I/O not available in browser

# ✅ GOOD: Use browser APIs
`fetch('/data.txt').then(r => r.text())`
```

3. **Check Ruby version compatibility:**
   - Opal targets specific Ruby version (usually 3.2)
   - Some Ruby 3.3+ features may not work

### Gem Loading Issues

**Symptom:**
```
Error: Gem 'my-gem' requires server-side dependencies
LoadError: cannot load 'listen' (Sprockets dependency)
```

**Solutions:**

1. **For Opal-compatible gems** (with `opal/` directory):
```ruby
# Gemfile
gem 'inesita'  # Has both lib/ and opal/ directories

# Works automatically - plugin prioritizes opal/ over lib/
require 'inesita'  # Loads from opal/, avoiding server-side code
```

2. **For gems without opal/ directory:**
```ruby
# Use only in server context or find browser-compatible alternative
# Gemfile (if using Rails)
group :development do
  gem 'listen'  # Server-only gem
end
```

3. **Check gem has Opal support:**
   - Look for `opal/` directory in gem
   - Check gem documentation for browser compatibility
   - Alternative: Use equivalent JavaScript library

### Source Map Issues

**Symptom:** Can't debug Opal code, source maps broken.

**Solution:**

1. **Enable in Vite config:**
```typescript
// vite.config.ts
export default defineConfig({
  build: {
    sourcemap: true
  }
});
```

2. **Check browser DevTools settings:**
   - Enable "Enable JavaScript source maps"
   - Enable "Enable CSS source maps"

## Runtime Errors

### "Opal already loaded" Warning

**Symptom:**
```
Opal already loaded. Loading twice can cause troubles
```

**Cause:** Opal runtime loaded multiple times.

**Solution:** Usually harmless warning, but can indicate:

1. **Multiple entry points loading Opal:**
```javascript
// ❌ BAD: Don't import Opal multiple times
import '@opal-runtime';  // In file A
import '@opal-runtime';  // In file B

// ✅ GOOD: Import once in main entry
// application.js
import '../opal/application.rb';  // Opal loads automatically
```

2. **Duplicate script tags:**
```html
<!-- ❌ BAD -->
<script src="/opal-runtime.js"></script>
<script src="/application.js"></script>  <!-- Also loads Opal -->

<!-- ✅ GOOD -->
<script type="module" src="/application.js"></script>
```

### WebSocket Connection Fails

**Symptom:**
```
WebSocket connection to 'ws://localhost:3000/' failed
```

**Solutions:**

1. **Check server is running:**
```bash
# Start WebSocket server
node server.mjs
```

2. **Check port matches:**
```ruby
# In controller
`const ws = new WebSocket('ws://localhost:3007')`  # Must match server port
```

3. **Check firewall:**
   - Allow WebSocket port
   - Check corporate proxy/firewall

4. **Use correct protocol:**
```ruby
# ❌ BAD: HTTP/HTTPS URL for WebSocket
`new WebSocket('http://localhost:3007')`

# ✅ GOOD: Use ws:// or wss://
`new WebSocket('ws://localhost:3007')`
```

### Chart.js Not Rendering

**Symptom:** Canvas exists but chart doesn't display.

**Solutions:**

1. **Check Chart.js is loaded:**
```javascript
// Browser console
console.log(window.Chart);  // Should not be undefined
```

2. **Check canvas size:**
```javascript
// Canvas needs explicit size
const canvas = document.querySelector('canvas');
console.log(canvas.width, canvas.height);  // Should be > 0
```

3. **Check chart instance created:**
```javascript
// After chart should be created
const canvas = document.querySelector('canvas');
console.log(canvas.chart || canvas.__chart);  // Should exist
```

4. **Destroy old chart before creating new:**
```ruby
def disconnect
  `
    if (this.chart) {
      this.chart.destroy();
      this.chart = null;
    }
  `
end
```

## Build & Deployment Issues

### Build Fails in Production

**Symptom:**
```
vite build fails with errors not present in dev
```

**Solutions:**

1. **Check environment variables:**
```bash
# Set production env vars
export NODE_ENV=production
export VITE_API_URL=https://api.example.com
vite build
```

2. **Clear cache:**
```bash
rm -rf node_modules/.vite
rm -rf dist
pnpm install
pnpm build
```

3. **Check for dev-only code:**
```ruby
# ❌ BAD: Dev-only dependencies in production code
require 'pry'  # Debug gem not available in production

# ✅ GOOD: Conditional requires
if ENV['RAILS_ENV'] == 'development'
  require 'pry'
end
```

### Large Bundle Size

**Symptom:** Built JavaScript file is very large (>1MB).

**Solutions:**

1. **Check what's included:**
```bash
pnpm exec vite build --mode production
# Look at dist/ file sizes
```

2. **Enable tree-shaking:**
```typescript
// vite.config.ts
export default defineConfig({
  build: {
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,  // Remove console.log
        drop_debugger: true  // Remove debugger
      }
    }
  }
});
```

3. **Split chunks:**
```typescript
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['@hotwired/stimulus'],
          charts: ['chart.js']
        }
      }
    }
  }
});
```

4. **Lazy load large dependencies:**
```javascript
// Instead of
import Chart from 'chart.js';

// Use dynamic import
const Chart = await import('chart.js');
```

## Performance Issues

### Slow HMR (Hot Module Replacement)

**Symptom:** Changes take long to reflect in browser.

**Solutions:**

1. **Reduce file watchers:**
```typescript
// vite.config.ts
export default defineConfig({
  server: {
    watch: {
      ignored: ['**/node_modules/**', '**/dist/**']
    }
  }
});
```

2. **Use faster disk (SSD):**
   - Move project to SSD if on HDD

3. **Reduce dependencies:**
   - Remove unused gems/packages
   - Use lighter alternatives

### Slow Page Load

**Symptom:** Page takes long to load/render.

**Solutions:**

1. **Check bundle size** (see above)

2. **Lazy load routes:**
```ruby
# Load heavy controllers only when needed
def load_heavy_feature
  `
    import('./controllers/heavy_controller.rb').then(module => {
      // Controller loaded
    });
  `
end
```

3. **Optimize images/assets:**
```bash
# Use compressed images
# Use modern formats (WebP, AVIF)
# Lazy load images
```

4. **Use CDN for dependencies:**
```html
<!-- Load from CDN instead of bundling -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
```

## Debugging Techniques

### 1. Browser DevTools

**Check Console:**
```javascript
// Enable verbose logging
localStorage.debug = '*';  // All logs
localStorage.debug = 'stimulus*';  // Only Stimulus logs
```

**Check Network:**
- Look for failed requests (404, 500)
- Check request/response headers
- Verify correct Content-Type

**Check Elements:**
- Inspect Stimulus data attributes
- Verify DOM structure matches expectations
- Check computed styles

### 2. Opal Debugging

**Add debug output:**
```ruby
def my_method
  puts "Debug: my_method called"  # Shows in browser console
  puts "Value: #{@value.inspect}"

  `console.log('JavaScript value:', someJsVariable)`
end
```

**Inspect Opal objects:**
```ruby
def connect
  # Print all instance variables
  instance_variables.each do |var|
    puts "#{var}: #{instance_variable_get(var).inspect}"
  end
end
```

### 3. Stimulus Debugging

**Log all controller lifecycles:**
```ruby
class MyController < StimulusController
  def connect
    puts "#{self.class.name} connected"
    `console.log('Element:', this.element)`
    `console.log('Targets:', this.targets)`
  end

  def disconnect
    puts "#{self.class.name} disconnected"
  end
end
```

**Inspect controller state:**
```javascript
// Browser console
const el = document.querySelector('[data-controller="my"]');
const app = window.Stimulus || window.application;
const controller = app.getControllerForElementAndIdentifier(el, 'my');

console.log('Controller:', controller);
console.log('Targets:', controller.targets);
console.log('Values:', controller.valueDescriptorMap);
```

### 4. Network Debugging

**Proxy requests:**
```typescript
// vite.config.ts
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        configure: (proxy, options) => {
          proxy.on('proxyReq', (proxyReq, req, res) => {
            console.log('Proxying:', req.method, req.url);
          });
        }
      }
    }
  }
});
```

**Mock API responses:**
```ruby
def fetch_data
  `
    // Mock during development
    if (import.meta.env.DEV) {
      return Promise.resolve({ data: 'mock' });
    }

    return fetch('/api/data').then(r => r.json());
  `
end
```

### 5. Time Travel Debugging

**Record controller state:**
```ruby
class MyController < StimulusController
  def connect
    `
      this.stateHistory = [];
      this.recordState = () => {
        this.stateHistory.push({
          timestamp: Date.now(),
          count: this.countValue,
          // ... other state
        });
      };
    `
  end

  def increment
    `
      this.countValue++;
      this.recordState();
    `
  end
end
```

## Getting Help

If you're still stuck:

1. **Check existing issues:**
   - [GitHub Issues](https://github.com/stofu1234/opal-vite/issues)

2. **Create minimal reproduction:**
   - Isolate the problem
   - Create smallest possible example
   - Share code on GitHub/CodeSandbox

3. **Provide context:**
   - Opal-Vite version
   - Node.js version
   - Ruby version (if using gems)
   - Browser version
   - Operating system
   - Full error message with stack trace

4. **Community resources:**
   - [Opal Gitter](https://gitter.im/opal/opal)
   - [Stack Overflow](https://stackoverflow.com/questions/tagged/opal)
   - [Stimulus Discourse](https://discuss.hotwired.dev/)

## Additional Resources

- [TESTING.md](./TESTING.md) - Testing strategies
- [MIGRATION.md](./MIGRATION.md) - Migration guide
- [examples/](./examples/) - Working examples
- [Opal Documentation](https://opalrb.com/)
- [Vite Documentation](https://vitejs.dev/)
- [Stimulus Handbook](https://stimulus.hotwired.dev/)

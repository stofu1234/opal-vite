# Migration Guide: Moving to Opal-Vite

This guide helps you migrate from traditional Opal setups (Sprockets, plain Opal, etc.) to Opal-Vite.

## Table of Contents

- [Why Migrate to Opal-Vite?](#why-migrate-to-opal-vite)
- [Migration Paths](#migration-paths)
- [Step-by-Step Migration](#step-by-step-migration)
- [Common Migration Scenarios](#common-migration-scenarios)
- [Troubleshooting](#troubleshooting)
- [Migration Checklist](#migration-checklist)

## Why Migrate to Opal-Vite?

### Benefits

1. **Faster Development**: Hot Module Replacement (HMR) for instant feedback
2. **Modern Build Tool**: Leverages Vite's optimized build pipeline
3. **Better DX**: Improved error messages, source maps, and debugging
4. **Smaller Bundles**: Tree-shaking and modern JavaScript output
5. **ES Modules**: Native ESM support for better performance
6. **Stimulus Integration**: Built-in support for Stimulus controllers
7. **TypeScript Support**: Optional TypeScript for type safety

### When to Migrate

✅ **Good time to migrate:**
- Starting a new project
- Major refactoring planned
- Performance issues with current setup
- Want to use modern JavaScript features

⚠️ **Consider carefully:**
- Large existing codebase (migrate incrementally)
- Tight deadlines (test thoroughly first)
- Heavy customizations to build process

## Migration Paths

### Path 1: From Sprockets (Rails Asset Pipeline)

```
Rails + Sprockets + Opal
         ↓
Rails + Opal-Vite
```

### Path 2: From Plain Opal

```
Plain Opal + Custom Build
         ↓
Opal-Vite
```

### Path 3: From Other Ruby-to-JS Solutions

```
Opal + Webpack/esbuild
         ↓
Opal-Vite
```

## Step-by-Step Migration

### Prerequisites

- Node.js 18 or higher
- pnpm, npm, or yarn
- Ruby 3.0 or higher (if using gems)

### Step 1: Project Setup

#### 1.1 Initialize Node.js Project

```bash
# Initialize package.json
pnpm init

# Or if using existing project
pnpm install
```

#### 1.2 Install Dependencies

```bash
# Install Vite and Opal plugin
pnpm add -D vite vite-plugin-opal

# Install Stimulus (optional but recommended)
pnpm add @hotwired/stimulus
```

#### 1.3 Create Vite Config

Create `vite.config.ts`:

```typescript
import { defineConfig } from 'vite';
import opal from 'vite-plugin-opal';

export default defineConfig({
  plugins: [
    opal({
      /* options */
    })
  ],
  server: {
    port: 3000
  }
});
```

### Step 2: Project Structure Migration

#### Old Structure (Sprockets)

```
app/
├── assets/
│   └── javascripts/
│       ├── application.js
│       └── components/
│           └── my_component.rb
```

#### New Structure (Opal-Vite)

```
app/
├── javascript/
│   └── application.js       # JavaScript entry
├── opal/
│   ├── application.rb        # Ruby/Opal entry
│   └── controllers/
│       └── my_controller.rb  # Stimulus controllers
└── styles/
    └── application.css       # Styles
```

### Step 3: Update Entry Points

#### 3.1 JavaScript Entry (`app/javascript/application.js`)

**Before (Sprockets):**
```javascript
//= require opal
//= require opal_ujs
//= require_tree .
```

**After (Opal-Vite):**
```javascript
// Import Stimulus
import { Application } from "@hotwired/stimulus"

// Expose Stimulus
window.Stimulus = Application.start()
window.application = window.Stimulus

// Import Opal code
import('../opal/application.rb')
```

#### 3.2 Opal Entry (`app/opal/application.rb`)

**Before:**
```ruby
require 'opal'
require 'opal-jquery'
require_tree './components'
```

**After:**
```ruby
# backtick_javascript: true
require 'native'
require 'opal_stimulus/stimulus_controller'

# Load controllers
require 'controllers/my_controller'

# Register all controllers
StimulusController.register_all!
```

### Step 4: Migrate Components to Controllers

#### Before (Plain Opal Component)

```ruby
# app/assets/javascripts/components/counter.rb
class Counter
  def initialize
    @count = 0
    setup_listeners
  end

  def setup_listeners
    `
      document.querySelector('.increment').addEventListener('click', function() {
        #{increment}
      });
    `
  end

  def increment
    @count += 1
    update_display
  end

  def update_display
    `document.querySelector('.count').textContent = #{@count}`
  end
end

Counter.new
```

#### After (Stimulus Controller)

```ruby
# app/opal/controllers/counter_controller.rb
# backtick_javascript: true

class CounterController < StimulusController
  self.targets = ["count"]
  self.values = { count: :number }

  def connect
    puts "Counter connected!"
  end

  def increment
    `this.countValue = this.countValue + 1`
  end

  def count_value_changed
    `this.countTarget.textContent = this.countValue`
  end
end
```

**HTML Update:**

```html
<!-- Before -->
<div>
  <span class="count">0</span>
  <button class="increment">+</button>
</div>

<!-- After -->
<div data-controller="counter" data-counter-count-value="0">
  <span data-counter-target="count">0</span>
  <button data-action="click->counter#increment">+</button>
</div>
```

### Step 5: Update HTML

#### Before (Rails with Sprockets)

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <%= javascript_include_tag 'application' %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

#### After (Rails with Vite)

Using [vite_rails](https://github.com/ElMassimo/vite_ruby):

```erb
<!DOCTYPE html>
<html>
  <head>
    <%= vite_javascript_tag 'application' %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>
```

Or standalone HTML:

```html
<!DOCTYPE html>
<html>
  <head>
    <title>My App</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/app/javascript/application.js"></script>
  </body>
</html>
```

### Step 6: Update Package Scripts

Add to `package.json`:

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  }
}
```

### Step 7: Environment Configuration

Create `.env` files:

```bash
# .env.development
VITE_API_URL=http://localhost:3000/api

# .env.production
VITE_API_URL=https://api.example.com
```

Access in code:

```ruby
# Opal code
api_url = `import.meta.env.VITE_API_URL`
```

## Common Migration Scenarios

### Scenario 1: Migrating jQuery Dependencies

**Before:**
```ruby
require 'opal-jquery'

Element.find('#myButton').on(:click) do
  alert 'Clicked!'
end
```

**After:**
```ruby
# backtick_javascript: true

class MyController < StimulusController
  def connect
    puts "Controller connected"
  end

  def handle_click
    `alert('Clicked!')`
  end
end
```

```html
<button data-controller="my" data-action="click->my#handle_click">
  Click me
</button>
```

### Scenario 2: Migrating Global State

**Before:**
```ruby
$app_state = {
  user: { name: 'John' },
  theme: 'light'
}
```

**After:**

Use Stimulus Values:

```ruby
class AppController < StimulusController
  self.values = {
    user: :object,
    theme: :string
  }

  def connect
    `
      this.userValue = { name: 'John' };
      this.themeValue = 'light';
    `
  end

  def user_value_changed
    `console.log('User changed:', this.userValue)`
  end
end
```

Or use LocalStorage:

```ruby
def save_user(user)
  `localStorage.setItem('user', JSON.stringify(#{user.to_n}))`
end

def load_user
  `JSON.parse(localStorage.getItem('user') || '{}')`
end
```

### Scenario 3: Migrating AJAX Requests

**Before (opal-jquery):**
```ruby
HTTP.get('/api/users') do |response|
  if response.ok?
    puts response.json
  end
end
```

**After (Fetch API):**
```ruby
def fetch_users
  `
    fetch('/api/users')
      .then(response => response.json())
      .then(users => {
        console.log('Users:', users);
        // Handle users
      })
      .catch(error => console.error('Error:', error));
  `
end
```

### Scenario 4: Migrating require_tree

**Before:**
```ruby
# application.rb
require_tree './components'
```

**After:**
```ruby
# application.rb
require 'components/counter'
require 'components/modal'
require 'components/form'
# ... or individually require each file
```

**Better approach:** Use controllers instead:

```ruby
require 'controllers/counter_controller'
require 'controllers/modal_controller'
require 'controllers/form_controller'

StimulusController.register_all!
```

### Scenario 5: Migrating Gems with opal/ Directory

Some Opal gems (like `inesita`) use both `lib/` and `opal/` directories:

**No changes needed!** The vite-plugin-opal automatically detects and adds both directories to the load path, prioritizing `opal/` over `lib/` for browser compatibility.

Example with Inesita:

```ruby
# Gemfile
gem 'inesita'
gem 'inesita-router'
```

```ruby
# app/opal/application.rb
require 'inesita'
require 'inesita-router'

# Works automatically - loads from opal/ directory
```

## Troubleshooting

### Issue: "Cannot find module"

**Problem:** Opal files not found during compilation.

**Solution:**
1. Check file paths are correct
2. Ensure `require` statements match file structure
3. Add explicit paths to `vite.config.ts`:

```typescript
opal({
  additionalLoadPaths: ['./app/lib', './vendor/opal']
})
```

### Issue: "backtick_javascript is required"

**Problem:** Inline JavaScript not working.

**Solution:** Add to top of Opal file:

```ruby
# backtick_javascript: true
```

### Issue: Controller not registering

**Problem:** Stimulus controller not found.

**Solution:**
1. Ensure controller inherits from `StimulusController`
2. Call `StimulusController.register_all!`
3. Check controller naming (use kebab-case in HTML)

```ruby
# MyThingController → my-thing
<div data-controller="my-thing">
```

### Issue: Opal gem dependencies

**Problem:** Server-side dependencies causing compilation errors.

**Solution:** Use Gemfile's `:opal` group or check gem for `opal/` directory:

```ruby
# Gemfile
group :opal do
  gem 'inesita'
end
```

The plugin automatically prioritizes `opal/` directories over `lib/` to avoid server-side dependencies.

### Issue: Build errors in production

**Problem:** Build works in dev but fails in production.

**Solution:**
1. Check environment variables
2. Ensure all dependencies installed
3. Verify paths are correct
4. Use absolute paths where possible

## Migration Checklist

### Pre-Migration

- [ ] Audit current dependencies
- [ ] Document current features
- [ ] Set up version control
- [ ] Create backup branch
- [ ] Test suite exists (if not, create basic tests)

### During Migration

- [ ] Install Node.js and pnpm
- [ ] Create `vite.config.ts`
- [ ] Set up new directory structure
- [ ] Migrate entry points
- [ ] Convert components to controllers
- [ ] Update HTML with Stimulus attributes
- [ ] Migrate styles (if needed)
- [ ] Update package.json scripts
- [ ] Configure environment variables

### Testing

- [ ] Test all features in development
- [ ] Test production build
- [ ] Verify HMR works
- [ ] Check source maps
- [ ] Test in multiple browsers
- [ ] Performance testing (bundle size, load time)
- [ ] Accessibility testing

### Post-Migration

- [ ] Update documentation
- [ ] Train team on new setup
- [ ] Monitor for issues
- [ ] Optimize bundle size
- [ ] Set up CI/CD for new build process

## Incremental Migration Strategy

For large projects, consider migrating incrementally:

### Phase 1: Setup (Week 1)
- Install Vite and dependencies
- Set up basic configuration
- Create new directory structure (parallel to old)

### Phase 2: Core Features (Week 2-3)
- Migrate most-used components
- Convert to Stimulus controllers
- Test thoroughly

### Phase 3: Secondary Features (Week 4-5)
- Migrate remaining components
- Update all HTML
- Remove old asset pipeline

### Phase 4: Cleanup (Week 6)
- Remove old code
- Optimize bundle
- Document changes
- Deploy to production

## Resources

- [Opal Documentation](https://opalrb.com/)
- [Vite Documentation](https://vitejs.dev/)
- [Stimulus Handbook](https://stimulus.hotwired.dev/)
- [vite_rails](https://github.com/ElMassimo/vite_ruby) - for Rails integration

## Getting Help

- GitHub Issues: [opal-vite/issues](https://github.com/stofu1234/opal-vite/issues)
- Opal Community: [Gitter](https://gitter.im/opal/opal)
- Stack Overflow: Tag with `opal` and `vite`

## Next Steps

After migration:

1. Review [TESTING.md](./TESTING.md) for testing strategies
2. Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues
3. Explore [examples/](./examples/) for advanced patterns
4. Set up CI/CD (see `.github/workflows/` examples)

Happy migrating! 🚀

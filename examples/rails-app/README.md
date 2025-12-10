# Opal-Vite-Rails Example Application

This is a minimal Rails application demonstrating the integration of Opal with Vite using the `opal-vite-rails` gem.

## Features

- ✅ Ruby code running in the browser (compiled by Opal)
- ✅ Fast development with Vite HMR
- ✅ Seamless Rails integration
- ✅ Source maps for debugging

## Setup

### 1. Install Ruby dependencies

```bash
bundle install
```

### 2. Install JavaScript dependencies

```bash
pnpm install
```

### 3. Start the development servers

In separate terminals:

**Terminal 1 - Vite dev server:**
```bash
bin/vite dev
```

**Terminal 2 - Rails server:**
```bash
rails server
```

### 4. Visit the application

Open your browser and navigate to:
```
http://localhost:3000
```

Check your browser console to see Ruby code output!

## Project Structure

```
app/
├── opal/
│   ├── application.rb          # Opal entry point
│   └── application_loader.js   # JavaScript loader for Opal
├── controllers/
│   └── welcome_controller.rb
└── views/
    └── welcome/
        └── index.html.erb       # Uses <%= opal_javascript_tag "application" %>

vite.config.ts                   # Vite configuration with opal plugin
```

## How It Works

1. **Development Mode:**
   - Vite dev server compiles `.rb` files on-the-fly
   - HMR provides instant updates when you edit Ruby code
   - Source maps allow debugging Ruby code in browser DevTools

2. **Production Mode:**
   - `rake opal_vite:compile` builds optimized JavaScript bundles
   - Manifest-based asset resolution
   - Integrated with Rails asset pipeline

## Available Rake Tasks

```bash
# Compile Opal assets for production
rake opal_vite:compile

# Clean compiled assets
rake opal_vite:clean

# Show configuration info
rake opal_vite:info
```

## Using Opal in Your Views

Add the Opal JavaScript to any view:

```erb
<%= opal_javascript_tag "application" %>
```

This automatically handles development vs production modes:
- **Development:** Loads from Vite dev server with HMR
- **Production:** Loads precompiled assets from manifest

## Writing Opal Code

Create `.rb` files in `app/opal/`:

```ruby
# app/opal/hello.rb
require 'native'

puts "Hello from Ruby!"

`
  document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM ready!');
  });
`
```

Import the loader in your view:
```erb
<%= opal_javascript_tag "hello" %>
```

## Next Steps

- Add more Opal files in `app/opal/`
- Create reusable Ruby modules
- Use Opal's `require` to organize your code
- Integrate with JavaScript libraries using Native module

## Documentation

- [Opal Documentation](https://opalrb.com/)
- [Vite Documentation](https://vitejs.dev/)
- [ViteRails Documentation](https://vite-ruby.netlify.app/)

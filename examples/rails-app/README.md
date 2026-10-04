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
├── frontend/                     # vite_ruby sourceCodeDir (config/vite.json)
│   ├── entrypoints/
│   │   └── application.js        # Vite entrypoint: imports ../opal/application.rb
│   └── opal/
│       └── application.rb        # Opal entry point
├── controllers/
│   └── welcome_controller.rb
└── views/
    └── welcome/
        └── index.html.erb        # <%= vite_javascript_tag 'application' %>

public/vite/                      # Production build (committed, served by the Docker image)
vite.config.ts                    # vite-plugin-ruby + vite-plugin-opal
```

## How It Works

1. **Development Mode:**
   - Vite dev server compiles `.rb` files on-the-fly
   - HMR provides instant updates when you edit Ruby code
   - Source maps allow debugging Ruby code in browser DevTools

2. **Production Mode:**
   - `RAILS_ENV=production bin/vite build` writes bundles and the manifest to `public/vite/`
   - `vite_javascript_tag` resolves the hashed file names from the manifest
   - The compiled Ruby imports the Opal runtime itself; no separate runtime tag is needed

## Deployment

The Docker image (also used by Railway, see `railway.json`) does not run
Node or the Opal compiler. It installs `Gemfile.production` and serves the
committed `public/vite/` build. After changing anything in `app/frontend/`,
rebuild and commit it:

```bash
RAILS_ENV=production bin/vite build
git add public/vite
```

## Writing Opal Code

Create `.rb` files in `app/frontend/opal/` and import them from an entrypoint:

```ruby
# app/frontend/opal/hello.rb
require 'native'

puts "Hello from Ruby!"
```

```js
// app/frontend/entrypoints/hello.js
import '../opal/hello.rb'
```

```erb
<%= vite_javascript_tag 'hello' %>
```

## Next Steps

- Add more Opal files in `app/frontend/opal/`
- Create reusable Ruby modules
- Use Opal's `require` to organize your code
- Integrate with JavaScript libraries using Native module

## Documentation

- [Opal Documentation](https://opalrb.com/)
- [Vite Documentation](https://vitejs.dev/)
- [ViteRails Documentation](https://vite-ruby.netlify.app/)

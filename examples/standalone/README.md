# Opal + Vite Standalone Example

This is a standalone example demonstrating Opal integration with Vite.

## Prerequisites

1. **Ruby** (>= 2.7.0)
2. **Node.js** (>= 18.0.0)
3. **pnpm** (>= 8.0.0)

## Setup

### 1. Install Ruby dependencies

From the project root:

```bash
cd gems/opal-vite
bundle install
cd ../..
```

### 2. Install Node.js dependencies

From the project root:

```bash
pnpm install
```

### 3. Build the Vite plugin

```bash
cd packages/vite-plugin-opal
pnpm build
cd ../..
```

## Running the Example

```bash
cd examples/standalone
pnpm dev
```

Then open http://localhost:3000 in your browser.

## What's Happening?

1. **Vite dev server starts** and serves `index.html`
2. **vite-plugin-opal** intercepts `.rb` file imports
3. **Ruby process spawns** to compile `main.rb` using the opal-vite gem
4. **Compiled JavaScript** is returned to the browser
5. **Opal runtime** is automatically injected into the page
6. **Your Ruby code runs** in the browser!

## Try It Out

1. Open the browser console to see Ruby output
2. Click the buttons to interact with Ruby objects
3. Edit `src/main.rb` and save - see HMR update the page instantly!

## Features Demonstrated

- ✅ Basic Ruby syntax and classes
- ✅ Console output (`puts`)
- ✅ Class instances and methods
- ✅ Module with class methods
- ✅ DOM interaction via backticks
- ✅ Hot Module Replacement (HMR)

## Troubleshooting

### "ruby: command not found"

Make sure Ruby is installed and in your PATH:

```bash
ruby --version
```

### "Cannot find module 'opal'"

Install the opal gem:

```bash
cd ../../gems/opal-vite
bundle install
```

### Port 3000 already in use

Change the port in `vite.config.ts`:

```typescript
server: {
  port: 3001  // or any other port
}
```

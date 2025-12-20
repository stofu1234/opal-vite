# Getting Started

opal-vite integrates [Opal](https://opalrb.com/) with [Vite](https://vitejs.dev/) to let you write Ruby code that runs in the browser.

## Prerequisites

- Node.js 18+
- Ruby 3.0+
- pnpm (recommended) or npm

## Quick Start

The fastest way to try opal-vite is with the practical-app example:

```bash
# Clone the repository
git clone https://github.com/stofu1234/opal-vite.git
cd opal-vite

# Install root dependencies
pnpm install

# Navigate to practical-app example
cd examples/practical-app

# Install dependencies
bundle install
pnpm install

# Run development server
pnpm dev
```

Open `http://localhost:3002` to see a full-featured Todo app built with Ruby!

## Project Structure

```
my-opal-app/
├── app/
│   └── opal/
│       ├── application.rb      # Main entry point
│       └── controllers/        # Stimulus controllers
├── index.html
├── vite.config.ts
├── package.json
└── Gemfile
```

## Next Steps

- [Installation Guide](/guide/installation) - Detailed installation instructions
- [API Reference](/api/v1/) - Learn about OpalVite Helpers
- [Troubleshooting](/guide/troubleshooting) - Common issues and solutions

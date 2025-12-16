# create-opal-vite

Scaffold Opal + Vite projects with one command.

## Usage

With npm:

```bash
npm create opal-vite@latest
```

With pnpm:

```bash
pnpm create opal-vite
```

With yarn:

```bash
yarn create opal-vite
```

Then follow the prompts!

You can also directly specify the project name and template:

```bash
# npm
npm create opal-vite@latest my-app -- --template basic

# pnpm
pnpm create opal-vite my-app --template basic

# yarn
yarn create opal-vite my-app --template basic
```

## Templates

Currently supported templates:

- **basic** - Simple Opal + Vite starter
- **stimulus** - Opal + Stimulus controllers *(coming soon)*
- **pwa** - Progressive Web App with offline support *(coming soon)*

## What Gets Scaffolded

A new project includes:

```
my-app/
├── app/
│   ├── javascript/
│   │   └── application.js   # JavaScript entry point
│   ├── opal/
│   │   └── application.rb    # Opal entry point
│   └── styles.css            # Application styles
├── index.html                # Main HTML
├── vite.config.ts            # Vite configuration
├── package.json
├── Gemfile
├── .gitignore
└── README.md
```

## After Scaffolding

```bash
cd my-app

# Install dependencies
npm install     # or pnpm install, yarn install
bundle install

# Start dev server
npm run dev     # or pnpm dev, yarn dev
```

Your app will be running at `http://localhost:5173`

## Available Scripts

In the generated project:

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build

## Requirements

- Node.js 18+ or 20+
- Ruby 3.0+
- npm/pnpm/yarn
- Bundler

## Features

- 🚀 **Lightning Fast HMR** - Instant feedback with Vite
- 💎 **Ruby in Browser** - Write Ruby code with Opal
- 📦 **Zero Config** - Sensible defaults, customize when needed
- 🎨 **CSS Support** - Import CSS directly
- 🔧 **Modern Tooling** - ESM, TypeScript config support
- 📱 **Mobile Ready** - Responsive templates

## Learn More

- [Opal Documentation](https://opalrb.com/)
- [Vite Documentation](https://vitejs.dev/)
- [Opal-Vite GitHub](https://github.com/yourusername/opal-vite)

## License

MIT

# Inesita + Opal + Vite Example

This example demonstrates how to build a frontend application using [Inesita](https://inesita.fazibear.me/), a Ruby frontend framework, integrated with Vite through opal-vite.

## What is Inesita?

Inesita is a simple, light Ruby frontend framework built on top of Opal. It provides:

- 🧩 **Component-based architecture** - Build reusable UI components
- ⚡ **Virtual DOM** - Fast and efficient rendering
- 💎 **Ruby DSL** - Write HTML using Ruby syntax
- 🔄 **Client-side routing** - Navigate between pages without page reloads
- 🗄️ **Dependency injection** - Share state across components

## Features in This Example

This example includes:

1. **Home Page** - Landing page with feature highlights and navigation
2. **Counter Component** - Interactive counter with increment/decrement/reset
3. **Todo List Component** - Manage tasks with add/toggle/remove functionality
4. **About Page** - Information about the tech stack
5. **Client-side Router** - Navigate between pages using Inesita Router
6. **State Management** - Shared store using dependency injection

## Getting Started

### Prerequisites

- Ruby 2.7 or higher
- Node.js 18 or higher
- pnpm (or npm)

### Installation

1. Install Ruby dependencies:

```bash
bundle install
```

2. Install JavaScript dependencies:

```bash
pnpm install
```

### Development

Run the development server:

```bash
pnpm dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Build for Production

```bash
pnpm build
```

The built files will be in the `dist` directory.

## Project Structure

```
inesita-app/
├── src/
│   ├── components/        # Inesita components
│   │   ├── home.rb       # Home page
│   │   ├── counter.rb    # Counter component
│   │   ├── todo_list.rb  # Todo list component
│   │   └── about.rb      # About page
│   ├── main.rb           # Application entry point
│   ├── router.rb         # Route configuration
│   ├── store.rb          # Shared state management
│   ├── main_loader.js    # JavaScript loader
│   └── styles.css        # Application styles
├── index.html            # HTML template
├── vite.config.ts        # Vite configuration
├── package.json          # npm dependencies
└── Gemfile               # Ruby dependencies
```

## How It Works

### Component Structure

Inesita components include the `Inesita::Component` module and define a `render` method:

```ruby
class Counter
  include Inesita::Component

  def render
    div class: 'counter' do
      button onclick: method(:increment) do
        text '+'
      end
      div { text store.counter }
    end
  end

  private

  def increment
    store.increase_counter
    render!  # Trigger re-render
  end
end
```

### State Management

The Store class uses dependency injection to share state:

```ruby
class Store
  include Inesita::Injection

  attr_accessor :counter

  def init
    @counter = 0
  end

  def increase_counter
    @counter += 1
  end
end
```

Components access the store via `store` method and call `render!` to update the UI.

### Routing

The Router defines routes mapping URLs to components:

```ruby
class Router
  include Inesita::Router

  def routes
    route '/', to: Home
    route '/counter', to: Counter
    route '/todos', to: TodoList
  end
end
```

Navigate programmatically using `router.go_to(path)`.

## Learn More

- [Inesita Documentation](https://inesita.fazibear.me/)
- [Opal Documentation](https://opalrb.com/)
- [Vite Documentation](https://vitejs.dev/)
- [opal-vite Repository](https://github.com/stofu1234/opal-vite)

## License

MIT

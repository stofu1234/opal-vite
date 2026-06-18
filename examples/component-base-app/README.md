# component-base-app

Demonstrates the framework-agnostic **`OpalComponent`** base class (issue #55) —
a lightweight component that holds state and re-renders, using only the native DOM
(no React / Vue / Stimulus).

## What it shows

`src/components/counter.rb` subclasses `OpalComponent`:

```ruby
class Counter < OpalComponent
  def initial_state = { count: 0 }

  def render
    "<button>count: #{state[:count]}</button>"
  end

  def after_render
    on('button', 'click') { set_state(count: state[:count] + 1) }
  end
end

Counter.new.mount('#app')
```

The base class provides:

- `state` / `set_state(partial)` — merge state and auto re-render
- `render` — return an HTML String
- `after_render` — hook to attach event listeners
- `on(selector, event)` / `query(selector)` — element-scoped DOM helpers
- `mount(selector_or_el)` — render into a DOM element

## Run

```bash
pnpm --filter opal-vite-component-base-app dev    # http://localhost:3031
pnpm --filter opal-vite-component-base-app build
```

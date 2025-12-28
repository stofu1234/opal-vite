# Example Applications

opal-vite includes several example applications that demonstrate different Stimulus API features.

## Counter App

[Live Demo](/playground/counter-app/) | [Source Code](https://github.com/stofu1234/opal-vite/tree/master/examples/counter-app)

A simple counter application demonstrating the **Stimulus Values API**.

**Features demonstrated:**
- `stimulus_value(:name)` - Get a value
- `set_stimulus_value(:name, value)` - Set a value
- `increment_stimulus_value(:name)` - Increment a numeric value
- `decrement_stimulus_value(:name)` - Decrement a numeric value
- Value change callbacks (`count_value_changed`)

**Location:** `examples/counter-app/`

```ruby
class CounterController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  self.values = { count: :number }
  self.targets = ["display"]

  def connect
    update_display
  end

  def increment
    increment_stimulus_value(:count)
  end

  def decrement
    decrement_stimulus_value(:count)
  end

  def reset
    set_stimulus_value(:count, 0)
  end

  def count_value_changed
    update_display
  end

  private

  def update_display
    target_set_text(:display, stimulus_value(:count).to_s)
  end
end
```

**Run locally:**
```bash
cd examples/counter-app
bundle install
pnpm install
pnpm dev
```

---

## CRUD App

[Live Demo](/playground/crud-app/) | [Source Code](https://github.com/stofu1234/opal-vite/tree/master/examples/crud-app)

A CRUD (Create, Read, Update, Delete) application demonstrating **Stimulus Action Parameters**.

**Features demonstrated:**
- `action_param(:name)` - Get action parameter
- `action_param_int(:id)` - Get integer parameter
- `has_action_param?(:name)` - Check if parameter exists
- `data-[controller]-[name]-param` HTML attribute syntax
- Modal dialogs with event communication

**Location:** `examples/crud-app/`

```ruby
class ListController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  self.targets = ["container", "template", "nameInput"]
  self.values = { items: :array }

  def edit
    # Get parameters from data-list-id-param, data-list-name-param attributes
    id = action_param_int(:id)
    name = action_param(:name)
    quantity = action_param_int(:quantity, 1) if has_action_param?(:quantity)

    dispatch_window_event('open-modal', { id: id, name: name, quantity: quantity })
  end

  def delete
    id = action_param_int(:id)
    # ... delete logic
  end
end
```

**HTML with action parameters:**
```html
<button data-action="click->list#edit"
        data-list-id-param="123"
        data-list-name-param="Item Name"
        data-list-quantity-param="5">
  Edit
</button>
```

**Run locally:**
```bash
cd examples/crud-app
bundle install
pnpm install
pnpm dev
```

---

## Tabs App

[Live Demo](/playground/tabs-app/) | [Source Code](https://github.com/stofu1234/opal-vite/tree/master/examples/tabs-app)

A tabbed interface demonstrating **Stimulus Outlets and Dispatch**.

**Features demonstrated:**
- Outlet connections (`self.outlets = ["panel"]`)
- `has_outlet?(:name)` - Check outlet existence
- `call_outlet(:name, :method)` - Call method on outlet
- `call_all_outlets(:name, :method)` - Call method on all outlets
- `dispatch_window_event(name, detail)` - Dispatch custom events
- `on_window_event(name)` - Listen to window events

**Location:** `examples/tabs-app/`

```ruby
# Tabs Controller
class TabsController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  self.targets = ["tab"]
  self.outlets = ["panel"]

  def select
    index = action_param_int(:index)
    activate_tab(index)
    show_panel_by_index(index)
  end

  private

  def show_panel_by_index(index)
    # Hide all panels via outlets
    call_all_outlets(:panel, :hide) if has_outlet?(:panel)
    # Dispatch event for panels to show
    dispatch_window_event('tabs:change', { index: index })
  end
end

# Panel Controller
class PanelController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  def connect
    on_window_event('tabs:change') do |event|
      detail = `#{event}.detail`
      index = `#{detail}.index`
      my_index = action_param_int(:index)
      index == my_index ? show : hide
    end
  end

  def show
    element_remove_class('panel-hidden')
  end

  def hide
    element_add_class('panel-hidden')
  end
end
```

**Run locally:**
```bash
cd examples/tabs-app
bundle install
pnpm install
pnpm dev
```

---

## Running Tests

Each example app includes E2E tests using Capybara + Cuprite:

```bash
cd examples/counter-app
pnpm dev &
bundle exec rspec
```

## Production Build

All example apps support production builds:

```bash
cd examples/counter-app
pnpm build    # Build for production
pnpm preview  # Preview production build
```

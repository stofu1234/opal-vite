# Stimulus API Helpers

New in v0.3.0: Full support for Stimulus's core APIs including Values, CSS Classes, Outlets, dispatch(), and Action Parameters.

## Values API

Access Stimulus values defined with `self.values = { name: :type }`.

```ruby
class CounterController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  # Define values using Ruby DSL
  self.values = { count: :number, label: :string }

  def increment
    increment_stimulus_value(:count)      # Increment by 1
    increment_stimulus_value(:count, 5)   # Increment by 5
  end

  def decrement
    decrement_stimulus_value(:count)
  end

  def reset
    set_stimulus_value(:count, 0)
  end

  def display
    count = stimulus_value(:count)
    label = stimulus_value(:label)
    target_set_text(:output, "#{label}: #{count}")
  end

  def toggle_feature
    toggle_stimulus_value(:enabled)  # Flip boolean value
  end

  def conditional_load
    if has_stimulus_value?(:api_url)
      fetch_json(stimulus_value(:api_url)) { |data| process(data) }
    end
  end
end
```

### Methods

| Method | Description |
|--------|-------------|
| `stimulus_value(name)` | Get the value |
| `set_stimulus_value(name, value)` | Set the value |
| `has_stimulus_value?(name)` | Check if value's data attribute exists |
| `increment_stimulus_value(name, amount=1)` | Increment numeric value |
| `decrement_stimulus_value(name, amount=1)` | Decrement numeric value |
| `toggle_stimulus_value(name)` | Toggle boolean value |

---

## CSS Classes API

Access CSS classes defined with `self.classes = [ "loading", "active" ]`.

```ruby
class FormController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  # Define CSS classes using Ruby DSL
  self.classes = ["loading", "success", "error"]

  def submit
    apply_class(this_element, :loading)

    fetch_json('/api/submit') do |response|
      remove_applied_class(this_element, :loading)

      if response['success']
        apply_class(this_element, :success)
      else
        apply_class(this_element, :error)
      end
    end
  end
end
```

```html
<form data-controller="form"
      data-form-loading-class="opacity-50 cursor-wait"
      data-form-success-class="border-green-500"
      data-form-error-class="border-red-500 shake">
</form>
```

### Methods

| Method | Description |
|--------|-------------|
| `get_class(name)` | Get single CSS class name |
| `get_classes(name)` | Get array of CSS class names |
| `has_class_definition?(name)` | Check if class is defined |
| `apply_class(element, name)` | Add CSS class to element |
| `apply_classes(element, name)` | Add all CSS classes to element |
| `remove_applied_class(element, name)` | Remove CSS class from element |
| `remove_applied_classes(element, name)` | Remove all CSS classes from element |

---

## Outlets API

Access outlets defined with `self.outlets = [ "result" ]`.

```ruby
class TabsController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  # Define outlets using Ruby DSL
  self.outlets = ["panel"]

  def select
    tab_id = action_param(:id)

    # Hide all panels
    call_all_outlets(:panel, 'hide')

    # Show selected panel
    get_outlets(:panel).each do |panel|
      if js_get(panel, 'idValue') == tab_id
        js_call_on(panel, 'show')
      end
    end
  end

  def connect
    return unless has_outlet?(:panel)

    # Initialize first panel as active
    first_panel = get_outlet(:panel)
    js_call_on(first_panel, 'show')
  end
end
```

```html
<div data-controller="tabs" data-tabs-panel-outlet=".panel">
  <button data-action="tabs#select" data-tabs-id-param="1">Tab 1</button>
  <button data-action="tabs#select" data-tabs-id-param="2">Tab 2</button>
</div>

<div class="panel" data-controller="panel" data-panel-id-value="1">Content 1</div>
<div class="panel" data-controller="panel" data-panel-id-value="2">Content 2</div>
```

### Methods

| Method | Description |
|--------|-------------|
| `has_outlet?(name)` | Check if outlet exists |
| `get_outlet(name)` | Get single outlet controller |
| `get_outlets(name)` | Get all outlet controllers |
| `get_outlet_element(name)` | Get outlet's element |
| `get_outlet_elements(name)` | Get all outlet elements |
| `call_outlet(name, method, *args)` | Call method on outlet |
| `call_all_outlets(name, method, *args)` | Call method on all outlets |

---

## dispatch() API

Emit custom events with controller identifier prefix.

```ruby
class ClipboardController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  def copy
    content = target_value(:source)

    # Dispatches "clipboard:copied" event
    stimulus_dispatch("copied", detail: { content: content })
  end

  def copy_with_confirm
    # Check if any listener cancelled the event
    if stimulus_dispatch_confirm("beforeCopy")
      do_copy
    end
  end
end
```

```html
<!-- Listen for the prefixed event -->
<div data-action="clipboard:copied->notification#show">
  <div data-controller="clipboard">
    <button data-action="clipboard#copy">Copy</button>
  </div>
</div>
```

### Methods

| Method | Description |
|--------|-------------|
| `stimulus_dispatch(name, detail:, target:, prefix:, bubbles:, cancelable:)` | Dispatch prefixed event |
| `stimulus_dispatch_confirm(name, detail:)` | Dispatch and check if cancelled |

---

## Action Parameters API

Access parameters from `data-[controller]-[name]-param` attributes.

```ruby
class ItemController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  def edit
    id = action_param_int(:id)        # Auto-parsed as integer
    name = action_param(:name)         # String

    open_editor(id, name)
  end

  def delete
    return unless has_action_param?(:id)

    id = action_param_int(:id)
    confirmed = action_param_bool(:confirm)

    if confirmed || confirm_delete
      remove_item(id)
    end
  end
end
```

```html
<button data-action="item#edit"
        data-item-id-param="123"
        data-item-name-param="My Item">
  Edit
</button>

<button data-action="item#delete"
        data-item-id-param="123"
        data-item-confirm-param="true">
  Delete
</button>
```

### Methods

| Method | Description |
|--------|-------------|
| `action_params` | Get all parameters as object |
| `action_param(name)` | Get parameter value |
| `action_param_int(name, default=0)` | Get as integer |
| `action_param_bool(name)` | Get as boolean |
| `has_action_param?(name)` | Check if parameter exists |

---

## Controller Access

Access controller properties and other controllers.

```ruby
class ModalController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  def open
    # Access controller properties
    console_log("Opening modal:", this_identifier)

    # Get parent controller
    parent = parent(this_element)
    form_controller = get_controller(parent, "form")

    if form_controller
      js_call_on(form_controller, 'validate')
    end
  end

  def check_scope
    # Check if element is in this controller's scope
    target = get_target(:content)
    console_log("In scope:", in_scope?(target))
  end
end
```

### Methods

| Method | Description |
|--------|-------------|
| `this_application` | Get Stimulus Application |
| `this_identifier` | Get controller identifier |
| `this_element` | Get controller element |
| `this_scope` | Get controller scope element |
| `get_controller(element, identifier)` | Get controller instance |
| `get_controllers(element, identifier)` | Get all controllers |
| `in_scope?(element)` | Check if element is in scope |

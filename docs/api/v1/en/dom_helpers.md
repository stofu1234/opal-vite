# DomHelpers API

Common DOM manipulation methods for Stimulus controllers.

## Usage

```ruby
require 'opal_vite/concerns/v1/dom_helpers'

class MyController < StimulusController
  include OpalVite::Concerns::V1::DomHelpers
end
```

---

## Custom Events

### dispatch_custom_event(event_name, detail = {}, target = nil)
Create and dispatch a custom event

```ruby
dispatch_custom_event('item-updated', { id: 123 })
dispatch_custom_event('click', {}, some_element)
```

### create_event(event_type, options = { bubbles: true })
Create a standard event

```ruby
event = create_event('click', { bubbles: true })
```

---

## Query Methods

### query(selector)
Query selector within controller element

```ruby
child = query('.child-element')
```

### query_all(selector)
Query all matching elements

```ruby
items = query_all('.item')
```

---

## Class Operations

### add_class(el, class_name)
Add CSS class

```ruby
add_class(element, 'active')
```

### remove_class(el, class_name)
Remove CSS class

```ruby
remove_class(element, 'hidden')
```

### toggle_class(el, class_name)
Toggle CSS class

```ruby
toggle_class(element, 'selected')
```

### has_class?(el, class_name)
Check if element has class

```ruby
if has_class?(element, 'disabled')
  return
end
```

---

## Timing

### set_timeout(delay_ms, &block)
Delayed execution

```ruby
set_timeout(1000) do
  puts 'After 1 second'
end
```

---

## Utility

### element_exists?(el)
Check if element exists (not null)

```ruby
if element_exists?(target)
  process(target)
end
```

---

## Style Operations

### set_style(el, property, value)
Set style property

```ruby
set_style(element, 'display', 'none')
```

### get_style(el, property)
Get style property

```ruby
display = get_style(element, 'display')
```

### show_element(el)
Show element (display: block)

```ruby
show_element(modal)
```

### hide_element(el)
Hide element (display: none)

```ruby
hide_element(modal)
```

---

## Example

```ruby
class ModalController < StimulusController
  include OpalVite::Concerns::V1::DomHelpers

  def open
    modal = query('.modal')
    show_element(modal)
    add_class(modal, 'animate-in')

    set_timeout(300) do
      dispatch_custom_event('modal:opened', { modal_id: 'main' })
    end
  end

  def close
    modal = query('.modal')
    remove_class(modal, 'animate-in')

    set_timeout(300) do
      hide_element(modal)
      dispatch_custom_event('modal:closed')
    end
  end
end
```

# ReactHelpers API

Helpers for React applications.

## Usage

```ruby
require 'opal_vite/concerns/v1/react_helpers'

class MyComponent
  include OpalVite::Concerns::V1::ReactHelpers
end
```

---

## React Access

### react
Get React object

```ruby
version = react.version
```

### react_dom
Get ReactDOM object

```ruby
root = react_dom.createRoot(container)
```

---

## Element Creation

### el(type, props = nil, *children)
Create React element (generic)

```ruby
el('div', { className: 'container' },
  el('h1', nil, 'Title'),
  el('p', nil, 'Content')
)
```

### div(props = nil, *children, &block)
Create div element

```ruby
div({ className: 'wrapper' }, 'Content')

# Block form
div({ className: 'wrapper' }) do
  'Dynamic content'
end
```

### span(props = nil, *children, &block)
Create span element

```ruby
span({ className: 'highlight' }, 'Text')
```

### button(props = nil, *children, &block)
Create button element

```ruby
button({ onClick: handler }, 'Click me')
```

### paragraph(props = nil, *children, &block)
Create p element

```ruby
paragraph({ className: 'description' }, 'Paragraph text')
```

### h1(props = nil, *children) / h2 / h3
Create heading elements

```ruby
h1(nil, 'Main Title')
h2({ className: 'section-title' }, 'Section')
```

---

## DOM

### query(selector) / query_all(selector)
Query elements

```ruby
container = query('#root')
items = query_all('.item')
```

### get_element_by_id(id)
Get element by ID

```ruby
root = get_element_by_id('root')
```

### create_element(tag)
Create DOM element

```ruby
div = create_element('div')
```

### set_html(element, html) / set_text(element, text)
Set innerHTML / textContent

```ruby
set_html(element, '<strong>Bold</strong>')
set_text(element, 'Plain text')
```

### add_class(element, *classes) / remove_class(element, *classes)
Add/remove classes

```ruby
add_class(element, 'active', 'visible')
remove_class(element, 'hidden')
```

---

## Events

### on_dom_ready(&block)
Execute when DOM is ready

```ruby
on_dom_ready do
  render_app
end
```

### on_window_event(event_name, &block)
Listen to window events

```ruby
on_window_event('resize') do |event|
  handle_resize
end
```

### off_window_event(event_name, handler)
Remove event listener

```ruby
off_window_event('resize', resize_handler)
```

---

## Dialogs

### alert_message(message)
Show alert

```ruby
alert_message('Operation completed')
```

### confirm_message(message)
Show confirm dialog

```ruby
if confirm_message('Delete this item?')
  delete_item
end
```

### prompt_message(message, default_value = '')
Show input dialog

```ruby
name = prompt_message('Enter name', 'Anonymous')
```

---

## Timing

### set_timeout(delay_ms, &block)
Delayed execution

```ruby
set_timeout(1000) do
  console_log('After 1 second')
end
```

### set_interval(interval_ms, &block)
Repeated execution

```ruby
timer = set_interval(5000) do
  poll_updates
end
```

### clear_timeout(id) / clear_interval(id)
Clear timer

```ruby
clear_interval(timer)
```

---

## LocalStorage

### storage_get(key) / storage_set(key, value)
LocalStorage operations

```ruby
storage_set('theme', 'dark')
theme = storage_get('theme')
```

### storage_remove(key)
Remove key

```ruby
storage_remove('temp')
```

---

## Fetch API

### fetch_url(url, options = nil)
Execute fetch (returns Promise)

```ruby
promise = fetch_url('/api/data')
promise.then { |response| response.json }
       .then { |data| process(data) }
```

---

## JSON

### parse_json(json_string)
Parse JSON

```ruby
data = parse_json('{"key": "value"}')
```

### to_json(object)
Convert to JSON string

```ruby
json = to_json({ key: 'value' })
```

---

## Console

### console_log(*args) / console_warn(*args) / console_error(*args)
Console output

```ruby
console_log('Debug:', data)
```

---

## Global

### window_get(key) / window_set(key, value)
Window property access

```ruby
window_set('myApp', app_instance)
app = window_get('myApp')
```

### window_delete(key)
Delete window property

```ruby
window_delete('tempData')
```

---

## Type Conversion

### parse_int(value, radix = 10) / parse_float(value)
Number parsing

```ruby
num = parse_int('42')
float = parse_float('3.14')
```

### parse_int_or(value, default = 0) / parse_float_or(value, default = 0.0)
Parse with default

```ruby
num = parse_int_or('abc', 0)  # => 0
```

### is_nan?(value)
NaN check

```ruby
if is_nan?(result)
  use_default_value
end
```

---

## Example

```ruby
require 'opal_vite/concerns/v1/react_helpers'

class CounterComponent
  include OpalVite::Concerns::V1::ReactHelpers

  def initialize
    @count = 0
  end

  def render
    div({ className: 'counter' },
      h1(nil, 'Counter'),
      paragraph({ className: 'count' }, @count.to_s),
      button({ onClick: method(:increment) }, '+'),
      button({ onClick: method(:decrement) }, '-'),
      button({ onClick: method(:reset) }, 'Reset')
    )
  end

  def increment
    @count += 1
    rerender
  end

  def decrement
    @count -= 1
    rerender
  end

  def reset
    @count = 0
    rerender
  end
end

# Mount
on_dom_ready do
  root = react_dom.createRoot(get_element_by_id('root'))
  component = CounterComponent.new
  root.render(component.render)
end
```

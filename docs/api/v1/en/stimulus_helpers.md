# StimulusHelpers API

DSL macros for Stimulus controllers. Reduces JavaScript backticks in Opal Stimulus controllers.

## Usage

```ruby
require 'opal_vite/concerns/v1/stimulus_helpers'

class MyController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers
end
```

---

## Target Operations

### has_target?(name)
Check if target exists

```ruby
if has_target?(:input)
  # target exists
end
```

### get_target(name)
Get target element

```ruby
element = get_target(:input)
```

### get_targets(name)
Get all targets of a type

```ruby
items = get_targets(:item)
```

### target_value(name) / target_set_value(name, value)
Get/set target value (for input fields)

```ruby
value = target_value(:input)
target_set_value(:input, 'new value')
```

### target_html(name) / target_set_html(name, html)
Get/set target innerHTML

```ruby
html = target_html(:output)
target_set_html(:output, '<strong>Updated</strong>')
```

### target_text(name) / target_set_text(name, text)
Get/set target textContent

```ruby
text = target_text(:label)
target_set_text(:label, 'New Label')
```

### target_data(name, attr) / target_set_data(name, attr, value)
Get/set data attributes on target

```ruby
id = target_data(:item, 'id')
target_set_data(:item, 'status', 'active')
```

### target_clear(name) / target_clear_html(name)
Clear target value/innerHTML

```ruby
target_clear(:input)
target_clear_html(:output)
```

---

## Target Style Methods

### set_target_style(name, property, value) / get_target_style(name, property)
Set/get style on target

```ruby
set_target_style(:box, 'background', 'red')
color = get_target_style(:box, 'color')
```

### show_target(name) / hide_target(name)
Show/hide target

```ruby
show_target(:modal)
hide_target(:modal)
```

### toggle_target_visibility(name)
Toggle target visibility

```ruby
toggle_target_visibility(:panel)
```

---

## Target Class Methods

### add_target_class(name, class_name)
Add CSS class to target

```ruby
add_target_class(:button, 'active')
```

### remove_target_class(name, class_name)
Remove CSS class from target

```ruby
remove_target_class(:button, 'active')
```

### toggle_target_class(name, class_name)
Toggle CSS class on target

```ruby
toggle_target_class(:button, 'selected')
```

### has_target_class?(name, class_name)
Check if target has class

```ruby
if has_target_class?(:button, 'disabled')
  # ...
end
```

---

## Timer Methods

### set_timeout(delay, &block)
Execute block after delay (ms)

```ruby
set_timeout(1000) do
  puts 'After 1 second'
end
```

### set_interval(interval, &block)
Execute block repeatedly

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

## LocalStorage Methods

### storage_get(key) / storage_set(key, value)
Basic localStorage operations

```ruby
storage_set('theme', 'dark')
theme = storage_get('theme')
```

### storage_get_json(key, default) / storage_set_json(key, value)
JSON-based localStorage operations

```ruby
todos = storage_get_json('todos', [])
storage_set_json('todos', todos)
```

### storage_remove(key)
Remove key from localStorage

```ruby
storage_remove('temp')
```

---

## Event Methods

### dispatch_window_event(name, detail = {})
Dispatch custom event on window

```ruby
dispatch_window_event('data-updated', { id: 123 })
```

### dispatch_event(name, detail = {})
Dispatch custom event on controller element

```ruby
dispatch_event('item-selected', { index: 0 })
```

### on_window_event(name, &block) / off_window_event(name, handler)
Listen to window events

```ruby
on_window_event('resize') do |event|
  handle_resize
end
```

### on_dom_ready(&block)
Execute when DOM is ready

```ruby
on_dom_ready do
  init_app
end
```

### prevent_default
Prevent default event behavior

```ruby
def submit(event)
  prevent_default
  # ...
end
```

### event_key / event_data(attr)
Get event information

```ruby
if event_key == 'Enter'
  submit
end
id = event_data('id')
```

---

## DOM Query Methods

### query(selector) / query_all(selector)
Query document

```ruby
el = query('#my-element')
items = query_all('.item')
```

### query_element(selector) / query_all_element(selector)
Query within controller element

```ruby
el = query_element('.child')
```

---

## Element Methods

### add_class(element, class_name) / remove_class / toggle_class / has_class?
Class manipulation

```ruby
add_class(el, 'active')
remove_class(el, 'hidden')
toggle_class(el, 'selected')
if has_class?(el, 'disabled')
```

### set_attr(element, attr, value) / get_attr / remove_attr / has_attr?
Attribute manipulation

```ruby
set_attr(el, 'disabled', 'true')
value = get_attr(el, 'data-id')
```

### set_style(element, property, value)
Set element style

```ruby
set_style(el, 'display', 'none')
```

### set_html(element, html) / set_text(element, text)
Set element content

```ruby
set_html(el, '<b>Bold</b>')
set_text(el, 'Plain text')
```

### get_value(element) / set_value(element, value) / focus(element)
Input operations

```ruby
val = get_value(input)
set_value(input, 'new value')
focus(input)
```

---

## DOM Creation Methods

### create_element(tag)
Create DOM element

```ruby
div = create_element('div')
```

### append_child(parent, child)
Append child element

```ruby
append_child(container, item)
```

### remove_element(element)
Remove element from DOM

```ruby
remove_element(old_item)
```

---

## Fetch API

### fetch_json(url, &block)
Fetch JSON with callback

```ruby
fetch_json('/api/data') do |data|
  process(data)
end
```

### fetch_json_promise(url)
Fetch JSON returning Promise

```ruby
promise = fetch_json_promise('/api/data')
```

### fetch_json_with_handlers(url, on_success:, on_error:)
Fetch with handlers

```ruby
fetch_json_with_handlers('/api/data',
  on_success: ->(data) { display(data) },
  on_error: ->(err) { show_error(err) }
)
```

---

## Promise Methods

### promise_all(promises) / promise_race(promises)
Promise combinators

```ruby
promise_all([fetch1, fetch2])
```

### js_then(promise, &block) / js_catch(promise, &block)
Promise chaining

```ruby
promise = fetch_json_promise('/api')
js_then(promise) { |data| process(data) }
js_catch(promise) { |err| handle_error(err) }
```

---

## JSON Methods

### json_parse(string) / json_stringify(obj)
JSON operations

```ruby
data = json_parse('{"key": "value"}')
json = json_stringify({ key: 'value' })
```

---

## Console Methods

### console_log(*args) / console_warn(*args) / console_error(*args)
Console output

```ruby
console_log('Debug:', data)
console_error('Error:', message)
```

---

## Type Conversion

### parse_int(value, radix = 10) / parse_float(value)
Parse numbers

```ruby
num = parse_int('42')
float = parse_float('3.14')
```

### parse_int_or(value, default) / parse_float_or(value, default)
Parse with default

```ruby
num = parse_int_or('abc', 0)  # => 0
```

### is_nan?(value)
Check if NaN

```ruby
if is_nan?(result)
  use_default
end
```

---

## JavaScript Interop

### js_prop(name) / js_set_prop(name, value)
Access controller properties

```ruby
js_set_prop('chartInstance', chart)
instance = js_prop('chartInstance')
```

### js_global(name) / js_global_exists?(name)
Access global objects

```ruby
if js_global_exists?('Chart')
  chart_class = js_global('Chart')
end
```

### js_new(klass, *args)
Create JavaScript instance

```ruby
chart = js_new(chart_class, canvas, config)
```

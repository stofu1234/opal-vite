# VueHelpers API

Helpers for Vue.js 3 applications.

## Usage

```ruby
require 'opal_vite/concerns/v1/vue_helpers'

class MyVueApp
  extend OpalVite::Concerns::V1::VueHelpers
end
```

---

## Vue Access

### vue
Get Vue object

```ruby
vue_version = VueHelpers.vue.version
```

### create_app(options = {})
Create Vue application

```ruby
app = VueHelpers.create_app({
  data: `function() { return { count: 0 }; }`,
  methods: `{
    increment() { this.count++; }
  }`,
  template: '<button @click="increment">{{ count }}</button>'
})
app.mount('#app')
```

---

## Reactivity

### vue_ref(initial_value)
Create reactive ref

```ruby
count = VueHelpers.vue_ref(0)
```

### vue_reactive(object)
Create reactive object

```ruby
state = VueHelpers.vue_reactive({ count: 0, name: 'Vue' })
```

### vue_computed(&getter)
Create computed property

```ruby
doubled = VueHelpers.vue_computed { state.count * 2 }
```

### vue_watch(source, &callback)
Watch reactive source

```ruby
VueHelpers.vue_watch(count) do |new_val, old_val|
  console_log("Changed: #{old_val} -> #{new_val}")
end
```

---

## Lifecycle Hooks

### on_mounted(&block)
When component is mounted

```ruby
VueHelpers.on_mounted do
  console_log('Component mounted')
end
```

### on_unmounted(&block)
When component is unmounted

```ruby
VueHelpers.on_unmounted do
  cleanup_resources
end
```

### on_updated(&block)
When component is updated

```ruby
VueHelpers.on_updated do
  console_log('Component updated')
end
```

### on_before_mount(&block) / on_before_unmount(&block)
Before mount/unmount

```ruby
VueHelpers.on_before_mount do
  prepare_data
end
```

---

## DOM

### query(selector)
Query single element

```ruby
element = VueHelpers.query('#my-element')
```

### query_all(selector)
Query all elements

```ruby
items = VueHelpers.query_all('.item')
```

### get_element_by_id(id)
Get element by ID

```ruby
element = VueHelpers.get_element_by_id('app')
```

### on_dom_ready(&block)
Execute when DOM is ready

```ruby
VueHelpers.on_dom_ready do
  init_app
end
```

---

## Timing

### set_timeout(delay_ms, &block)
Delayed execution

```ruby
VueHelpers.set_timeout(1000) do
  console_log('After 1 second')
end
```

### set_interval(interval_ms, &block)
Repeated execution

```ruby
timer = VueHelpers.set_interval(5000) do
  fetch_updates
end
```

### clear_timeout(id) / clear_interval(id)
Clear timer

```ruby
VueHelpers.clear_interval(timer)
```

---

## LocalStorage

### storage_get(key) / storage_set(key, value)
LocalStorage operations

```ruby
VueHelpers.storage_set('theme', 'dark')
theme = VueHelpers.storage_get('theme')
```

### storage_remove(key)
Remove key

```ruby
VueHelpers.storage_remove('temp')
```

---

## JSON

### parse_json(json_string)
Parse JSON

```ruby
data = VueHelpers.parse_json('{"key": "value"}')
```

### to_json_string(object)
Convert to JSON string

```ruby
json = VueHelpers.to_json_string({ key: 'value' })
```

---

## Console

### console_log(*args) / console_warn(*args) / console_error(*args)
Console output

```ruby
VueHelpers.console_log('Debug:', data)
```

---

## Global

### window_get(key) / window_set(key, value)
Window property access

```ruby
VueHelpers.window_set('myGlobal', value)
value = VueHelpers.window_get('myGlobal')
```

---

## Type Conversion

### parse_int(value, radix = 10) / parse_float(value)
Number parsing

```ruby
num = VueHelpers.parse_int('42')
float = VueHelpers.parse_float('3.14')
```

### is_nan?(value)
NaN check

```ruby
if VueHelpers.is_nan?(result)
  console_log('Invalid number')
end
```

---

## Example

```ruby
require 'opal_vite/concerns/v1/vue_helpers'

class CounterApp
  extend OpalVite::Concerns::V1::VueHelpers

  TEMPLATE = <<~HTML
    <div>
      <p>Count: {{ count }}</p>
      <button @click="increment">+</button>
      <button @click="decrement">-</button>
    </div>
  HTML

  def self.create_app
    options = {
      data: `function() { return { count: 0 }; }`,
      methods: `{
        increment() { this.count++; },
        decrement() { this.count--; }
      }`,
      template: TEMPLATE,
      mounted: `function() {
        console.log('Counter mounted');
      }`
    }

    VueHelpers.create_app(options)
  end

  def self.mount(selector)
    app = create_app
    app.mount(selector)
    console_log("CounterApp mounted to #{selector}")
  end
end

# Usage
VueHelpers.on_dom_ready do
  CounterApp.mount('#app')
end
```

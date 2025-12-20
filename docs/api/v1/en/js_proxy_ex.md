# JsProxyEx API

JavaScript object wrapper class and helpers for Ruby-like JS interop.

## Usage

```ruby
require 'opal_vite/concerns/v1/js_proxy_ex'

class MyController < StimulusController
  include OpalVite::Concerns::V1::JsProxyEx
end
```

---

## Global Objects

### local_storage
Access LocalStorage

```ruby
local_storage.get_item('key')
local_storage.set_item('key', 'value')
local_storage.remove_item('key')
```

### session_storage
Access SessionStorage

```ruby
session_storage.get_item('key')
session_storage.set_item('key', 'value')
```

### js_json
JSON utilities

```ruby
data = js_json.parse('{"key": "value"}')
json = js_json.stringify({ key: 'value' })
```

### js_console
Console access

```ruby
js_console.log('Debug message')
js_console.warn('Warning!')
js_console.error('Error!')
```

---

## Object Creation

### new_event(type, options = {})
Create Event object

```ruby
event = new_event('click', { bubbles: true })
```

### new_custom_event(type, detail = {})
Create CustomEvent

```ruby
event = new_custom_event('my-event', { data: 'value' })
```

### new_url(url_string)
Create URL object

```ruby
url = new_url('https://example.com/path?query=1')
url.hostname  # => 'example.com'
url.pathname  # => '/path'
```

### new_regexp(pattern, flags = '')
Create RegExp

```ruby
regex = new_regexp('[a-z]+', 'i')
regex.test('Hello')  # => true
```

### new_date(value = nil)
Create Date object

```ruby
now = new_date
specific = new_date('2024-01-01')
```

### date_now
Get current timestamp (milliseconds)

```ruby
timestamp = date_now
```

---

## Wrapper Utilities

### wrap_js(obj)
Wrap existing JS object in JsObject

```ruby
element = query('#my-element')
wrapped = wrap_js(element)
wrapped.class_list.add('active')
```

### js_array_to_ruby(js_array)
Convert JS array to Ruby array (with JsObject wrapping)

```ruby
js_items = query_all('.item')
ruby_items = js_array_to_ruby(js_items)
ruby_items.each { |item| item.class_list.add('processed') }
```

### new_js_array
Create empty JS array

```ruby
arr = new_js_array
arr.push('item1')
arr.push('item2')
```

---

## JsObject Class

`JsObject` wraps JavaScript objects for Ruby-like access.

### Property Access (snake_case to camelCase auto-conversion)

```ruby
element = wrap_js(query('#my-element'))

# snake_case automatically converts to camelCase
element.text_content          # => element.textContent
element.inner_html            # => element.innerHTML
element.class_list            # => element.classList

# Property setting
element.text_content = 'New text'
```

### Method Calls

```ruby
element = wrap_js(query('#my-element'))

# Method calls also convert snake_case to camelCase
element.get_attribute('data-id')    # => element.getAttribute('data-id')
element.set_attribute('class', 'x') # => element.setAttribute('class', 'x')
element.add_event_listener('click') { |e| ... }
```

### Array Access

```ruby
obj = wrap_js(`{ items: ['a', 'b', 'c'] }`)
obj[:items]     # => JsObject-wrapped array
obj['items']    # => same
```

### Native Value Access

```ruby
element = wrap_js(query('#my-element'))
native = element.to_n  # => Original JavaScript object
```

---

## RegExpWrapper Class

Regular expression wrapper.

```ruby
regex = new_regexp('[0-9]+')

# Test
regex.test('abc123')  # => true
regex.test('abc')     # => false

# Match
result = regex.exec('abc123def')
result[0]  # => '123'
```

---

## Example

```ruby
class FormController < StimulusController
  include OpalVite::Concerns::V1::JsProxyEx

  def validate
    # URL parsing
    url = new_url(target_value(:url_input))
    if url.protocol != 'https:'
      show_error('Please enter an HTTPS URL')
      return
    end

    # Regex validation
    email_regex = new_regexp('^[^@]+@[^@]+\\.[^@]+$')
    unless email_regex.test(target_value(:email_input))
      show_error('Please enter a valid email address')
      return
    end

    # Save to LocalStorage
    local_storage.set_item('last_url', url.href)
  end
end
```

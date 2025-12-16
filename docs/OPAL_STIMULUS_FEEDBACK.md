# opal_stimulus Feedback / Feature Requests

This document summarizes issues and feature requests discovered while developing with `opal_stimulus` gem in the opal-vite project.

## Context

We are building Stimulus controllers in Ruby using `opal_stimulus`. The goal is to write Ruby-like code as much as possible, minimizing the use of JavaScript backticks.

## Issues Discovered

### 1. Nested Property Access Fails with method_missing

**Problem:** When accessing nested properties through `JS::Proxy`, `method_missing` fails to convert snake_case to camelCase properly.

**Example:**
```ruby
# This fails with: undefined method `rules` for #<JS::Proxy:0xe6>
rules = field.dataset.rules

# Workaround: Use [] accessor
rules = field.dataset[:rules]  # Still doesn't work with JS::Proxy

# Current solution: wrap with custom JsObject
rules = wrap_js(field.dataset)[:rules]  # Works
```

**Expected:** `field.dataset.rules` should work and automatically convert to `field.dataset.rules` in JavaScript.

### 2. Stimulus Target Methods Not Converted (has_xxx_target, xxx_target)

**Problem:** Stimulus provides `hasXxxTarget` and `xxxTarget` methods, but calling `has_xxx_target` from Ruby returns `undefined` instead of being converted to `hasXxxTarget`.

**Example:**
```ruby
# This returns undefined
has_total_fields_target  # Expected: this.hasTotalFieldsTarget

# Workaround: Use backticks
`this.hasTotalFieldsTarget`  # Works
```

**Expected:** `has_total_fields_target` should be converted to `this.hasTotalFieldsTarget`.

### 3. Event Callback Not Properly Wrapped

**Problem:** When using `add_event_listener` with a block, the event object passed to the callback is not properly wrapped as `JS::Proxy`.

**Example:**
```ruby
# Event object is raw JavaScript, not wrapped
window.add_event_listener('click') do |event|
  # event.current_target fails - event is not wrapped
end

# Workaround: Use backticks for event listeners
`window.addEventListener('show-toast', (e) => {
  this.$show(e.detail.message);
});`
```

**Expected:** The event object should be automatically wrapped so Ruby methods work.

### 4. Controller Instance Not Accessible via to_n

**Problem:** Inside a StimulusController, `self.to_n` raises `undefined method 'to_n'`, making it difficult to access the native controller instance.

**Example:**
```ruby
class MyController < StimulusController
  def some_method
    ctrl = self.to_n  # Fails: undefined method `to_n`

    # Workaround: Use `this` inside backticks
    `this.someTarget`  # Works
  end
end
```

**Expected:** `self.to_n` should return the native JavaScript controller instance.

### 5. Array Length/Index Access Requires Backticks

**Problem:** When working with arrays (like `field_targets`), `.length` and index access `[i]` don't work properly through JS::Proxy.

**Example:**
```ruby
targets = field_targets  # Returns Array
count = targets.length   # Returns Ruby Array length (may not match)

# Workaround: Use backticks
count = `#{targets.to_n}.length`
item = `#{targets.to_n}[#{i}]`
```

**Expected:** `targets.length` and `targets[i]` should work properly for JavaScript arrays.

### 6. nil? Check on JS::Proxy Objects Fails

**Problem:** Calling `.nil?` on a JS::Proxy object that wraps null/undefined raises an error trying to access `$$pristine` property.

**Example:**
```ruby
form_group = field.closest('.form-group')
return if form_group.nil?  # Fails: Cannot read properties of undefined (reading '$$pristine')

# Workaround: Use backticks for null check
return unless `#{form_group.to_n} != null`
```

**Expected:** `.nil?` should work on JS::Proxy objects that wrap null/undefined.

## Workaround: JsProxyEx Module

We created a `JsProxyEx` module to work around these issues:

```ruby
module JsProxyEx
  # Wrap JS::Proxy objects for enhanced access
  def wrap_js(obj)
    return nil if obj.nil?
    native = obj.respond_to?(:to_n) ? obj.to_n : obj
    JsObject.new(native)
  end

  # Stimulus target helpers
  def has_target?(target_name)
    camel_name = snake_to_camel(target_name.to_s)
    has_method = "has#{camel_name[0].upcase}#{camel_name[1..-1]}Target"
    `this[#{has_method}]`
  end

  def set_target_text(target_name, text)
    camel_name = snake_to_camel(target_name.to_s)
    has_method = "has#{camel_name[0].upcase}#{camel_name[1..-1]}Target"
    target_method = "#{camel_name}Target"
    `
      if (this[#{has_method}]) {
        this[#{target_method}].textContent = #{text};
      }
    `
  end

  # JsObject class with snake_case -> camelCase conversion
  class JsObject
    def method_missing(name, *args, &block)
      camel_name = snake_to_camel(name.to_s)
      # ... method call or property access
    end

    def [](key)
      camel_key = snake_to_camel(key.to_s)
      result = `#{@native}[#{camel_key}]`
      wrap_result(result)
    end
  end
end
```

## Feature Requests

### 1. Enhanced method_missing for JS::Proxy

Add automatic snake_case to camelCase conversion in `method_missing`:

```ruby
# Desired behavior
field.dataset.rules        # -> field.dataset.rules
event.current_target       # -> event.currentTarget (already works!)
element.query_selector_all # -> element.querySelectorAll (already works!)
```

### 2. Stimulus-Specific Helpers

Add built-in support for Stimulus target patterns:

```ruby
# Desired API
has_target?(:submit_btn)      # -> this.hasSubmitBtnTarget
target(:submit_btn)           # -> this.submitBtnTarget
targets(:field)               # -> this.fieldTargets
```

### 3. Controller Instance Access

Make `self.to_n` work inside StimulusController:

```ruby
class MyController < StimulusController
  def method
    native_ctrl = self.to_n  # Should return JS controller instance
  end
end
```

### 4. Proper Event Wrapping in Callbacks

Automatically wrap event objects in callbacks:

```ruby
window.add_event_listener('click') do |event|
  event.current_target  # Should work (event wrapped as JS::Proxy)
  event.prevent_default # Should work
end
```

## Summary Table

| Issue | Current Workaround | Desired Solution |
|-------|-------------------|------------------|
| `dataset.rules` fails | `wrap_js(dataset)[:rules]` | Native support |
| `has_xxx_target` undefined | Backticks with `this.hasXxxTarget` | Auto-conversion |
| Event not wrapped in callback | Backticks for event listeners | Auto-wrap |
| `self.to_n` fails | Use `this` in backticks | Make `to_n` work |
| Array `.length` incorrect | `targets.to_n.length` in backticks | Native support |
| `.nil?` on null JS object fails | `form_group.to_n != null` in backticks | Handle null properly |

## Files Created

- `examples/form-validation-app/app/opal/concerns/js_proxy_ex.rb` - Extended proxy module
- `docs/OPAL_STIMULUS_FEEDBACK.md` - This document

---

**Created:** 2025-12-16
**opal_stimulus version:** (current)
**opal version:** 3.2.0

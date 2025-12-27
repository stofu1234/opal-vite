# CRUD App - Action Parameters Feature Showcase

This document highlights the key features demonstrated in this example app.

## 1. Action Parameter Helpers

### `action_param(:name)` - Get Parameter Value

**Use Case:** Get any action parameter (auto-typed by Stimulus)

**Example from `list_controller.rb`:**
```ruby
def edit
  # Get string parameter
  name = action_param(:name)
  puts "  name: #{name} (via action_param)"
end
```

**HTML:**
```html
<button data-action="list#edit" data-list-name-param="Laptop">
  Edit
</button>
```

---

### `action_param_int(:id, default)` - Get Integer Parameter

**Use Case:** Get numeric parameters (IDs, quantities) with optional default

**Example from `list_controller.rb`:**
```ruby
def edit
  # Get integer parameter
  id = action_param_int(:id)
  puts "  id: #{id} (via action_param_int)"
end

def delete
  # Use action_param_int to get the ID parameter
  id = action_param_int(:id)
  puts "Delete action called with ID: #{id}"
end
```

**HTML:**
```html
<button data-action="list#delete" data-list-id-param="123">
  Delete
</button>
```

---

### `has_action_param?(:name)` - Check Parameter Exists

**Use Case:** Check for optional parameters before accessing

**Example from `list_controller.rb`:**
```ruby
def edit
  # Check for optional parameter
  quantity = if has_action_param?(:quantity)
    action_param_int(:quantity, 1)
  else
    1
  end
  puts "  quantity: #{quantity} (via has_action_param? check)"
end

def delete
  # Validate required parameter exists
  unless has_action_param?(:id)
    puts "Error: No ID parameter provided"
    return
  end

  # Use optional parameter for better UX
  name = action_param(:name) if has_action_param?(:name)
  puts "Deleted item: #{name}" if name
end
```

**HTML:**
```html
<!-- Optional parameter -->
<button
  data-action="list#edit"
  data-list-id-param="123"
  data-list-name-param="Laptop"
  data-list-quantity-param="2">
  Edit
</button>
```

---

## 2. Dynamic Parameter Setting

The app demonstrates dynamically setting action parameters in Ruby:

**From `list_controller.rb` - `render_item` method:**
```ruby
def render_item(item)
  # ... create element from template ...

  # Set action parameters on Edit button
  edit_btn = query_element_in(element, '[data-action*="edit"]')
  if edit_btn
    set_attr(edit_btn, 'data-list-id-param', item_id)
    set_attr(edit_btn, 'data-list-name-param', item_name)
    set_attr(edit_btn, 'data-list-quantity-param', item_quantity)
  end

  # Set action parameters on Delete button
  delete_btn = query_element_in(element, '[data-action*="delete"]')
  if delete_btn
    set_attr(delete_btn, 'data-list-id-param', item_id)
    set_attr(delete_btn, 'data-list-name-param', item_name)
  end
end
```

This shows how to programmatically add action parameters to buttons created from templates.

---

## 3. Complete CRUD Operations

### Create (Add)
- User inputs name and quantity
- `list#add` action creates new item
- Item gets unique ID and is added to array

### Read (Display)
- Items rendered from array using template
- Statistics show total items and quantity
- Empty state when no items exist

### Update (Edit)
- Click Edit button with action parameters
- Modal opens with current values
- Save dispatches event to update item

### Delete
- Click Delete button with action parameters
- Item filtered out of array
- List re-renders

---

## 4. Inter-Controller Communication

### List → Modal Communication

**List Controller dispatches event:**
```ruby
def edit
  id = action_param_int(:id)
  name = action_param(:name)
  quantity = action_param_int(:quantity, 1)

  # Open modal with item data
  dispatch_window_event('open-modal', {
    id: id,
    name: name,
    quantity: quantity
  })
end
```

**Modal Controller listens:**
```ruby
def connect
  on_window_event('open-modal') do |e|
    detail = `#{e}.detail`
    id = `#{detail}.id`
    name = `#{detail}.name`
    quantity = `#{detail}.quantity`

    # Store ID and populate form
    `this.currentItemId = #{id}`
    target_set_value(:nameInput, name)
    target_set_value(:quantityInput, quantity)

    open_modal
  end
end
```

### Modal → List Communication

**Modal dispatches update:**
```ruby
def save
  dispatch_window_event('item-updated', {
    id: item_id,
    name: name,
    quantity: quantity
  })
end
```

**List Controller listens:**
```ruby
def connect
  on_window_event('item-updated') do |e|
    detail = `#{e}.detail`
    id = parse_int(`#{detail}.id`)
    name = `#{detail}.name`
    quantity = parse_int(`#{detail}.quantity`)

    update_item(id, name, quantity)
  end
end
```

---

## 5. Stimulus Values API

The app uses Stimulus values for reactive state:

```ruby
class ListController < StimulusController
  self.values = { items: :array }

  def initialize
    super
    @items_value = `[]`  # Initialize as JS array
  end

  def add_item(name, quantity)
    items = get_value(:items)  # Get current array
    `#{items}.push(#{new_item})`
    set_value(:items, items)   # Trigger update
  end
end
```

Benefits:
- Reactive: Changes automatically persist to data attributes
- Type-safe: Array type ensures proper handling
- Accessible: Can be read/written from JS or Ruby

---

## 6. Template Cloning

Efficient DOM rendering using HTML templates:

```ruby
def render_item(item)
  # Clone template
  clone = clone_template(:template)
  element = template_first_child(clone)

  # Populate with data
  name_el = query_element_in(element, '[data-name]')
  set_text(name_el, item_name)

  # Set action parameters
  edit_btn = query_element_in(element, '[data-action*="edit"]')
  set_attr(edit_btn, 'data-list-id-param', item_id)

  # Add to DOM
  append_child(container, element)
end
```

---

## Key Takeaways

1. **Type Safety**: `action_param_int` ensures numeric values
2. **Clean Code**: Ruby methods instead of JS backticks
3. **Validation**: `has_action_param?` for robust error handling
4. **Defaults**: Built-in fallback values
5. **Dynamic**: Parameters set programmatically at runtime
6. **Pattern**: `data-[controller]-[name]-param` convention

## Testing the Features

1. **Add items** - Test basic CRUD create
2. **Edit items** - Test action parameters with 3 params (id, name, quantity)
3. **Delete items** - Test action parameters with 2 params (id, name)
4. **Check console** - See detailed logs of parameter usage
5. **View statistics** - Confirm reactive updates work

Each action demonstrates a different aspect of the Action Parameters API!

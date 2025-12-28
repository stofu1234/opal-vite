# CRUD App - Stimulus Action Parameters Demo

This example demonstrates how to use **Stimulus Action Parameters** with Opal and Vite.

## Features Demonstrated

### 1. Action Parameters API

The app showcases all three action parameter helper methods from `StimulusHelpers`:

- **`action_param(:name)`** - Get action parameter value (auto-typed by Stimulus)
- **`action_param_int(:id, default)`** - Get integer parameter with optional default
- **`has_action_param?(:name)`** - Check if a parameter exists

### 2. HTML Attribute Syntax

Action parameters are passed via data attributes:

```html
<button
  data-action="list#edit"
  data-list-id-param="123"
  data-list-name-param="Item Name"
  data-list-quantity-param="5">
  Edit
</button>
```

Pattern: `data-[controller]-[param-name]-param="value"`

### 3. Ruby Controller Usage

```ruby
class ListController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  def edit
    # Get integer parameter
    id = action_param_int(:id)

    # Get string parameter
    name = action_param(:name)

    # Check if optional parameter exists
    if has_action_param?(:quantity)
      quantity = action_param_int(:quantity, 1)
    end

    # Use the parameters...
  end
end
```

## Project Structure

```
crud-app/
├── index.html                    # Main HTML with Tailwind CDN
├── package.json                  # Dependencies
├── vite.config.ts                # Vite configuration
├── src/
│   └── main.js                   # Entry point, loads Opal
└── app/
    └── opal/
        ├── application.rb        # Loads controllers
        └── controllers/
            ├── list_controller.rb    # CRUD operations with action params
            └── modal_controller.rb   # Edit modal
```

## Running the Example

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start development server:
   ```bash
   npm run dev
   ```

3. Open browser to: http://localhost:3005

## How It Works

### Adding Items
- Enter name and quantity
- Click "Add" or press Enter
- Item is added to the list with a unique ID

### Editing Items
- Click "Edit" button on any item
- Action parameters (`id`, `name`, `quantity`) are passed to `list#edit`
- Modal opens with pre-filled values
- Save changes to update the item

### Deleting Items
- Click "Delete" button on any item
- Action parameters (`id`, `name`) are passed to `list#delete`
- Item is removed from the list

### Action Parameters in Action

When you click "Edit" on an item:

1. **HTML sets parameters:**
   ```html
   <button
     data-action="click->list#edit"
     data-list-id-param="1"
     data-list-name-param="Laptop"
     data-list-quantity-param="2">
     Edit
   </button>
   ```

2. **Stimulus passes them in event.params:**
   ```javascript
   event.params = { id: 1, name: "Laptop", quantity: 2 }
   ```

3. **Ruby controller extracts them:**
   ```ruby
   def edit
     id = action_param_int(:id)        # => 1
     name = action_param(:name)         # => "Laptop"
     quantity = action_param_int(:quantity)  # => 2
   ```

## Key Concepts

### Type Conversion
Stimulus automatically converts parameters based on their pattern:
- Numbers: `data-list-id-param="123"` → `123` (Number)
- Strings: `data-list-name-param="Item"` → `"Item"` (String)
- Booleans: `data-list-active-param="true"` → `true` (Boolean)

### Helper Methods Comparison

| Method | Use Case | Returns |
|--------|----------|---------|
| `action_param(:name)` | Any parameter type | Original type (as set by Stimulus) |
| `action_param_int(:id)` | Numeric IDs | Integer or default (0) |
| `has_action_param?(:name)` | Optional parameters | Boolean |

### Optional Parameters

Use `has_action_param?` for optional parameters:

```ruby
def edit
  id = action_param_int(:id)  # Required

  # Optional parameter with fallback
  category = if has_action_param?(:category)
    action_param(:category)
  else
    "uncategorized"
  end
end
```

## Benefits

1. **Type Safety** - `action_param_int` ensures integer values
2. **Clean Code** - No manual `event.params` access in backticks
3. **Ruby-friendly** - Idiomatic Ruby methods instead of JavaScript
4. **Error Handling** - Built-in checks with `has_action_param?`
5. **Defaults** - `action_param_int(:id, 0)` provides fallback values

## Related Documentation

- [Stimulus Action Parameters](https://stimulus.hotwired.dev/reference/actions#action-parameters)
- [StimulusHelpers API](../../gems/opal-vite/opal/opal_vite/concerns/v1/stimulus_helpers.rb)
- [Opal Ruby](https://opalrb.com/)

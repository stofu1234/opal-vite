# Storable API

LocalStorage persistence helpers with automatic JSON serialization.

## Usage

```ruby
require 'opal_vite/concerns/v1/storable'

class MyController < StimulusController
  include OpalVite::Concerns::V1::Storable
end
```

---

## Methods

### storage_get(key)
Get value from LocalStorage (auto-parses JSON)

```ruby
todos = storage_get('todos')
# => [{ "id" => 1, "text" => "Buy milk" }, ...]
```

Returns `nil` if key doesn't exist.

### storage_set(key, data)
Save value to LocalStorage (auto-stringifies to JSON)

```ruby
storage_set('todos', [
  { id: 1, text: 'Buy milk' },
  { id: 2, text: 'Walk dog' }
])
```

### storage_remove(key)
Remove key from LocalStorage

```ruby
storage_remove('temp_data')
```

---

## Example

```ruby
class TodoController < StimulusController
  include OpalVite::Concerns::V1::Storable

  STORAGE_KEY = 'todos'

  def connect
    @todos = storage_get(STORAGE_KEY) || []
    render_todos
  end

  def add_todo
    text = target_value(:input)
    @todos << { id: generate_id, text: text, completed: false }
    save_todos
    render_todos
  end

  def toggle_todo
    id = event_data_int('id')
    todo = @todos.find { |t| t['id'] == id }
    todo['completed'] = !todo['completed'] if todo
    save_todos
    render_todos
  end

  def delete_todo
    id = event_data_int('id')
    @todos.reject! { |t| t['id'] == id }
    save_todos
    render_todos
  end

  private

  def save_todos
    storage_set(STORAGE_KEY, @todos)
  end
end
```

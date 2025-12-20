# Storable API

LocalStorage を使ったデータ永続化のためのヘルパーです。

## 使用方法

```ruby
require 'opal_vite/concerns/v1/storable'

class MyController < StimulusController
  include OpalVite::Concerns::Storable
end
```

---

## メソッド

### storage_get(key)
LocalStorage から値を取得（JSON パース済み）

```ruby
todos = storage_get('todos')
# => [{ "id" => 1, "text" => "Buy milk" }, ...]
```

値が存在しない場合は `nil` を返します。

### storage_set(key, data)
LocalStorage に値を保存（自動的に JSON 化）

```ruby
storage_set('todos', [
  { id: 1, text: 'Buy milk' },
  { id: 2, text: 'Walk dog' }
])
```

### storage_remove(key)
LocalStorage からキーを削除

```ruby
storage_remove('temp_data')
```

---

## 使用例

```ruby
class TodoController < StimulusController
  include OpalVite::Concerns::Storable

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

  def save_todos
    storage_set(STORAGE_KEY, @todos)
  end
end
```

# ReactHelpers API

React アプリケーション構築のためのヘルパーです。

## 使用方法

```ruby
require 'opal_vite/concerns/v1/react_helpers'

class MyComponent
  include ReactHelpers
end
```

---

## React アクセス

### react
React オブジェクトを取得

```ruby
version = react.version
```

### react_dom
ReactDOM オブジェクトを取得

```ruby
root = react_dom.createRoot(container)
```

---

## 要素作成

### el(type, props = nil, *children)
React 要素を作成（汎用）

```ruby
el('div', { className: 'container' },
  el('h1', nil, 'Title'),
  el('p', nil, 'Content')
)
```

### div(props = nil, *children, &block)
div 要素を作成

```ruby
div({ className: 'wrapper' }, 'Content')

# ブロック形式
div({ className: 'wrapper' }) do
  'Dynamic content'
end
```

### span(props = nil, *children, &block)
span 要素を作成

```ruby
span({ className: 'highlight' }, 'Text')
```

### button(props = nil, *children, &block)
button 要素を作成

```ruby
button({ onClick: handler }, 'Click me')
```

### paragraph(props = nil, *children, &block)
p 要素を作成

```ruby
paragraph({ className: 'description' }, 'Paragraph text')
```

### h1(props = nil, *children) / h2 / h3
見出し要素を作成

```ruby
h1(nil, 'Main Title')
h2({ className: 'section-title' }, 'Section')
```

---

## DOM

### query(selector) / query_all(selector)
要素を取得

```ruby
container = query('#root')
items = query_all('.item')
```

### get_element_by_id(id)
ID で要素を取得

```ruby
root = get_element_by_id('root')
```

### create_element(tag)
DOM 要素を作成

```ruby
div = create_element('div')
```

### set_html(element, html) / set_text(element, text)
innerHTML / textContent を設定

```ruby
set_html(element, '<strong>Bold</strong>')
set_text(element, 'Plain text')
```

### add_class(element, *classes) / remove_class(element, *classes)
クラスの追加/削除

```ruby
add_class(element, 'active', 'visible')
remove_class(element, 'hidden')
```

---

## イベント

### on_dom_ready(&block)
DOM 準備完了時に実行

```ruby
on_dom_ready do
  render_app
end
```

### on_window_event(event_name, &block)
window イベントをリッスン

```ruby
on_window_event('resize') do |event|
  handle_resize
end
```

### off_window_event(event_name, handler)
イベントリスナーを削除

```ruby
off_window_event('resize', resize_handler)
```

---

## ダイアログ

### alert_message(message)
アラートを表示

```ruby
alert_message('処理が完了しました')
```

### confirm_message(message)
確認ダイアログを表示

```ruby
if confirm_message('削除しますか？')
  delete_item
end
```

### prompt_message(message, default_value = '')
入力ダイアログを表示

```ruby
name = prompt_message('名前を入力', 'Anonymous')
```

---

## タイマー

### set_timeout(delay_ms, &block)
遅延実行

```ruby
set_timeout(1000) do
  console_log('1秒後')
end
```

### set_interval(interval_ms, &block)
繰り返し実行

```ruby
timer = set_interval(5000) do
  poll_updates
end
```

### clear_timeout(id) / clear_interval(id)
タイマーをクリア

```ruby
clear_interval(timer)
```

---

## LocalStorage

### storage_get(key) / storage_set(key, value)
LocalStorage の操作

```ruby
storage_set('theme', 'dark')
theme = storage_get('theme')
```

### storage_remove(key)
キーを削除

```ruby
storage_remove('temp')
```

---

## Fetch API

### fetch_url(url, options = nil)
fetch を実行（Promise を返す）

```ruby
promise = fetch_url('/api/data')
promise.then { |response| response.json }
       .then { |data| process(data) }
```

---

## JSON

### parse_json(json_string)
JSON をパース

```ruby
data = parse_json('{"key": "value"}')
```

### to_json(object)
JSON 文字列に変換

```ruby
json = to_json({ key: 'value' })
```

---

## コンソール

### console_log(*args) / console_warn(*args) / console_error(*args)
コンソール出力

```ruby
console_log('Debug:', data)
```

---

## グローバル

### window_get(key) / window_set(key, value)
window プロパティの取得/設定

```ruby
window_set('myApp', app_instance)
app = window_get('myApp')
```

### window_delete(key)
window プロパティを削除

```ruby
window_delete('tempData')
```

---

## 型変換

### parse_int(value, radix = 10) / parse_float(value)
数値パース

```ruby
num = parse_int('42')
float = parse_float('3.14')
```

### parse_int_or(value, default = 0) / parse_float_or(value, default = 0.0)
デフォルト値付きパース

```ruby
num = parse_int_or('abc', 0)  # => 0
```

### is_nan?(value)
NaN チェック

```ruby
if is_nan?(result)
  use_default_value
end
```

---

## 使用例

```ruby
require 'opal_vite/concerns/v1/react_helpers'

class CounterComponent
  include ReactHelpers

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

# マウント
on_dom_ready do
  root = react_dom.createRoot(get_element_by_id('root'))
  component = CounterComponent.new
  root.render(component.render)
end
```

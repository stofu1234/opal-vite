# StimulusHelpers API

Stimulus コントローラで使用するためのヘルパーメソッド集です。JavaScript のバッククォート記法を減らし、Ruby らしいコードを書けます。

## 使用方法

```ruby
require 'opal_vite/concerns/v1/stimulus_helpers'

class MyController < StimulusController
  include OpalVite::Concerns::StimulusHelpers
end
```

---

## Target 操作

### has_target?(name)
ターゲットが存在するかチェック

```ruby
if has_target?(:input)
  # 処理
end
```

### get_target(name)
ターゲット要素を取得

```ruby
element = get_target(:input)
```

### get_targets(name)
同名の全ターゲットを配列で取得

```ruby
items = get_targets(:item)
items.each { |item| ... }
```

### target_value(name) / target_set_value(name, value)
ターゲットの value 属性の取得/設定

```ruby
text = target_value(:input)
target_set_value(:input, 'new value')
```

### target_html(name) / target_set_html(name, html)
ターゲットの innerHTML の取得/設定

```ruby
html = target_html(:output)
target_set_html(:output, '<p>Hello</p>')
```

### target_text(name) / target_set_text(name, text)
ターゲットの textContent の取得/設定

```ruby
text = target_text(:label)
target_set_text(:label, 'New Label')
```

### target_clear(name)
ターゲットの value をクリア

```ruby
target_clear(:input)  # value = ''
```

### target_focus(name) / target_blur(name)
ターゲットにフォーカス/アンフォーカス

```ruby
target_focus(:input)
```

---

## Target クラス操作

### add_target_class(name, class_name)
ターゲットにクラスを追加

```ruby
add_target_class(:container, 'active')
```

### remove_target_class(name, class_name)
ターゲットからクラスを削除

```ruby
remove_target_class(:container, 'active')
```

### toggle_target_class(name, class_name)
ターゲットのクラスをトグル

```ruby
toggle_target_class(:panel, 'expanded')
```

### has_target_class?(name, class_name)
ターゲットがクラスを持つかチェック

```ruby
if has_target_class?(:button, 'disabled')
  # 処理
end
```

---

## Target スタイル操作

### show_target(name) / hide_target(name)
ターゲットの表示/非表示

```ruby
show_target(:modal)
hide_target(:modal)
```

### toggle_target_visibility(name)
表示状態をトグル

```ruby
toggle_target_visibility(:dropdown)
```

### set_target_style(name, property, value)
スタイルプロパティを設定

```ruby
set_target_style(:box, 'backgroundColor', '#ff0000')
```

---

## イベント

### dispatch_event(name, detail = {})
コントローラ要素でカスタムイベントを発火

```ruby
dispatch_event('todo:added', { id: 1, text: 'New todo' })
```

### dispatch_window_event(name, detail = {})
window でカスタムイベントを発火

```ruby
dispatch_window_event('theme:changed', { theme: 'dark' })
```

### on_window_event(name, &block)
window のイベントをリッスン

```ruby
on_window_event('resize') do |event|
  console_log('Window resized')
end
```

### on_controller_event(name, &block)
コントローラ要素のイベントをリッスン

```ruby
on_controller_event('click') do |event|
  console_log('Clicked!')
end
```

### prevent_default
デフォルト動作を防止

```ruby
def submit(event)
  prevent_default
  # フォーム処理
end
```

### event_key
キーボードイベントのキー名を取得

```ruby
def keydown(event)
  if event_key == 'Enter'
    submit_form
  end
end
```

---

## タイマー

### set_timeout(delay, &block)
遅延実行

```ruby
timer_id = set_timeout(1000) do
  console_log('1秒後に実行')
end
```

### set_interval(delay, &block)
繰り返し実行

```ruby
interval_id = set_interval(5000) do
  fetch_updates
end
```

### clear_timeout(timer_id) / clear_interval(timer_id)
タイマーをキャンセル

```ruby
clear_timeout(timer_id)
clear_interval(interval_id)
```

---

## LocalStorage

### storage_get(key) / storage_set(key, value)
文字列の取得/保存

```ruby
value = storage_get('theme')
storage_set('theme', 'dark')
```

### storage_get_json(key, default = nil) / storage_set_json(key, value)
JSON の取得/保存

```ruby
todos = storage_get_json('todos', [])
storage_set_json('todos', todos)
```

### storage_remove(key)
キーを削除

```ruby
storage_remove('temp_data')
```

---

## DOM クエリ

### query(selector) / query_all(selector)
document 全体からクエリ

```ruby
element = query('#main')
items = query_all('.item')
```

### query_element(selector) / query_all_element(selector)
コントローラ要素内からクエリ

```ruby
input = query_element('input[type="text"]')
buttons = query_all_element('button')
```

---

## DOM 操作

### create_element(tag)
要素を作成

```ruby
div = create_element('div')
```

### append_child(parent, child)
子要素を追加

```ruby
list = get_target(:list)
item = create_element('li')
append_child(list, item)
```

### remove_element(element)
要素を削除

```ruby
remove_element(get_target(:item))
```

### set_html(element, html) / set_text(element, text)
innerHTML / textContent を設定

```ruby
set_html(element, '<strong>Bold</strong>')
set_text(element, 'Plain text')
```

---

## 要素クラス/属性

### add_class(element, class_name) / remove_class(element, class_name)
クラスの追加/削除

```ruby
add_class(element, 'active')
remove_class(element, 'hidden')
```

### toggle_class(element, class_name)
クラスをトグル

```ruby
toggle_class(element, 'expanded')
```

### set_attr(element, attr, value) / get_attr(element, attr)
属性の設定/取得

```ruby
set_attr(button, 'disabled', 'true')
value = get_attr(input, 'data-id')
```

### focus(element)
要素にフォーカス

```ruby
focus(get_target(:input))
```

---

## Fetch API

### fetch_json(url, &success_block)
JSON を取得してコールバック

```ruby
fetch_json('/api/todos') do |data|
  console_log('Got todos:', data)
end
```

### fetch_json_with_handlers(url, on_success:, on_error:)
成功/エラーハンドラ付き

```ruby
fetch_json_with_handlers('/api/data',
  on_success: ->(data) { process(data) },
  on_error: ->(error) { show_error(error) }
)
```

### fetch_all_json(urls)
複数 URL を並列取得

```ruby
promise = fetch_all_json(['/api/a', '/api/b'])
js_then(promise) do |results|
  console_log(results)
end
```

---

## Promise

### js_then(promise, &block)
Promise の成功時処理

```ruby
promise = fetch_json_promise('/api/data')
js_then(promise) do |data|
  console_log(data)
end
```

### js_catch(promise, &block)
Promise のエラー時処理

```ruby
js_catch(promise) do |error|
  console_error('Error:', error)
end
```

### promise_all(promises)
全 Promise の完了を待機

```ruby
all = promise_all([promise1, promise2])
```

---

## 型変換

### parse_int(value, radix = 10)
整数にパース

```ruby
num = parse_int('42')
hex = parse_int('ff', 16)
```

### parse_float(value)
浮動小数点にパース

```ruby
num = parse_float('3.14')
```

### parse_int_or(value, default = 0)
パース失敗時にデフォルト値を返す

```ruby
num = parse_int_or('abc', 0)  # => 0
```

---

## JSON

### json_parse(json_string)
JSON 文字列をパース

```ruby
data = json_parse('{"key": "value"}')
```

### json_stringify(obj)
オブジェクトを JSON 文字列に

```ruby
json = json_stringify({ key: 'value' })
```

---

## コンソール

### console_log(*args) / console_warn(*args) / console_error(*args)
コンソール出力

```ruby
console_log('Debug:', data)
console_warn('Warning!')
console_error('Error:', error)
```

---

## 日付/時刻

### js_timestamp
現在のタイムスタンプ（ミリ秒）

```ruby
now = js_timestamp
```

### js_date(value = nil)
Date オブジェクト作成

```ruby
now = js_date
specific = js_date('2024-01-01')
```

### js_iso_date
ISO 形式の日付文字列

```ruby
iso = js_iso_date  # => "2024-01-01T00:00:00.000Z"
```

---

## 数学

### js_random
0-1 のランダム値

```ruby
r = js_random
```

### random_int(max)
0 から max-1 のランダム整数

```ruby
dice = random_int(6) + 1
```

### js_min(a, b) / js_max(a, b)
最小値/最大値

```ruby
smaller = js_min(10, 20)
larger = js_max(10, 20)
```

### js_abs(num) / js_round(num) / js_floor(num) / js_ceil(num)
数学関数

```ruby
absolute = js_abs(-5)
rounded = js_round(3.7)
```

---

## グローバルオブジェクト

### js_global_exists?(name)
グローバル変数の存在チェック

```ruby
if js_global_exists?('Chart')
  # Chart.js が読み込まれている
end
```

### js_global(name)
グローバル変数を取得

```ruby
chart_class = js_global('Chart')
```

### js_new(klass, *args)
JavaScript クラスのインスタンス作成

```ruby
chart = js_new(js_global('Chart'), canvas, options)
```

# JsProxyEx API

JavaScript オブジェクトを Ruby らしく操作するためのラッパークラスとヘルパーです。

## 使用方法

```ruby
require 'opal_vite/concerns/v1/js_proxy_ex'

class MyController < StimulusController
  include OpalVite::Concerns::JsProxyEx
end
```

---

## グローバルオブジェクト

### local_storage
LocalStorage へのアクセス

```ruby
local_storage.get_item('key')
local_storage.set_item('key', 'value')
local_storage.remove_item('key')
```

### session_storage
SessionStorage へのアクセス

```ruby
session_storage.get_item('key')
session_storage.set_item('key', 'value')
```

### js_json
JSON ユーティリティ

```ruby
data = js_json.parse('{"key": "value"}')
json = js_json.stringify({ key: 'value' })
```

### js_console
コンソールアクセス

```ruby
js_console.log('Debug message')
js_console.warn('Warning!')
js_console.error('Error!')
```

---

## オブジェクト作成

### new_event(type, options = {})
Event オブジェクトを作成

```ruby
event = new_event('click', { bubbles: true })
```

### new_custom_event(type, detail = {})
CustomEvent を作成

```ruby
event = new_custom_event('my-event', { data: 'value' })
```

### new_url(url_string)
URL オブジェクトを作成

```ruby
url = new_url('https://example.com/path?query=1')
url.hostname  # => 'example.com'
url.pathname  # => '/path'
```

### new_regexp(pattern, flags = '')
正規表現を作成

```ruby
regex = new_regexp('[a-z]+', 'i')
regex.test('Hello')  # => true
```

### new_date(value = nil)
Date オブジェクトを作成

```ruby
now = new_date
specific = new_date('2024-01-01')
```

### date_now
現在のタイムスタンプ（ミリ秒）

```ruby
timestamp = date_now
```

---

## ラッパーユーティリティ

### wrap_js(obj)
既存の JS オブジェクトを JsObject でラップ

```ruby
element = query('#my-element')
wrapped = wrap_js(element)
wrapped.class_list.add('active')
```

### js_array_to_ruby(js_array)
JS 配列を Ruby 配列（JsObject ラップ済み）に変換

```ruby
js_items = query_all('.item')
ruby_items = js_array_to_ruby(js_items)
ruby_items.each { |item| item.class_list.add('processed') }
```

### new_js_array
空の JS 配列を作成

```ruby
arr = new_js_array
arr.push('item1')
arr.push('item2')
```

---

## JsObject クラス

`JsObject` は JavaScript オブジェクトを Ruby らしく操作するためのラッパーです。

### プロパティアクセス（snake_case → camelCase 自動変換）

```ruby
element = wrap_js(query('#my-element'))

# snake_case で書くと camelCase に自動変換
element.text_content          # => element.textContent
element.inner_html            # => element.innerHTML
element.class_list            # => element.classList

# プロパティ設定
element.text_content = 'New text'
```

### メソッド呼び出し

```ruby
element = wrap_js(query('#my-element'))

# メソッド呼び出しも snake_case → camelCase 変換
element.get_attribute('data-id')    # => element.getAttribute('data-id')
element.set_attribute('class', 'x') # => element.setAttribute('class', 'x')
element.add_event_listener('click') { |e| ... }
```

### 配列アクセス

```ruby
obj = wrap_js(`{ items: ['a', 'b', 'c'] }`)
obj[:items]     # => JsObject ラップされた配列
obj['items']    # => 同上
```

### ネイティブ値の取得

```ruby
element = wrap_js(query('#my-element'))
native = element.to_n  # => 元の JavaScript オブジェクト
```

---

## RegExpWrapper クラス

正規表現のラッパーです。

```ruby
regex = new_regexp('[0-9]+')

# テスト
regex.test('abc123')  # => true
regex.test('abc')     # => false

# マッチ
result = regex.exec('abc123def')
result[0]  # => '123'
```

---

## 使用例

```ruby
class FormController < StimulusController
  include OpalVite::Concerns::JsProxyEx

  def validate
    # URL のパース
    url = new_url(target_value(:url_input))
    if url.protocol != 'https:'
      show_error('HTTPS URLを入力してください')
      return
    end

    # 正規表現でのバリデーション
    email_regex = new_regexp('^[^@]+@[^@]+\.[^@]+$')
    unless email_regex.test(target_value(:email_input))
      show_error('有効なメールアドレスを入力してください')
      return
    end

    # LocalStorage に保存
    local_storage.set_item('last_url', url.href)
  end
end
```

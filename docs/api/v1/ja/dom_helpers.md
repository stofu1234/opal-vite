# DomHelpers API

DOM 操作のためのヘルパーメソッド集です。

## 使用方法

```ruby
require 'opal_vite/concerns/v1/dom_helpers'

class MyController < StimulusController
  include OpalVite::Concerns::DomHelpers
end
```

---

## イベント

### dispatch_custom_event(event_name, detail = {}, target = nil)
カスタムイベントを発火

```ruby
# window に発火（デフォルト）
dispatch_custom_event('my-event', { data: 'value' })

# 特定の要素に発火
dispatch_custom_event('my-event', { data: 'value' }, element)
```

### create_event(event_type, options = {})
イベントオブジェクトを作成

```ruby
event = create_event('click', { bubbles: true })
```

---

## DOM クエリ

### query(selector)
コントローラ要素内で単一要素を検索

```ruby
input = query('input[type="text"]')
```

### query_all(selector)
コントローラ要素内で全要素を検索

```ruby
buttons = query_all('button')
```

---

## クラス操作

### add_class(element, class_name)
クラスを追加

```ruby
add_class(element, 'active')
```

### remove_class(element, class_name)
クラスを削除

```ruby
remove_class(element, 'hidden')
```

### toggle_class(element, class_name)
クラスをトグル

```ruby
toggle_class(element, 'expanded')
```

### has_class?(element, class_name)
クラスの存在をチェック

```ruby
if has_class?(element, 'disabled')
  return
end
```

---

## スタイル操作

### set_style(element, property, value)
スタイルを設定

```ruby
set_style(element, 'display', 'none')
set_style(element, 'backgroundColor', '#fff')
```

### get_style(element, property)
スタイルを取得

```ruby
display = get_style(element, 'display')
```

### show_element(element)
要素を表示（display: block）

```ruby
show_element(modal)
```

### hide_element(element)
要素を非表示（display: none）

```ruby
hide_element(modal)
```

---

## ユーティリティ

### set_timeout(delay_ms, &block)
遅延実行

```ruby
set_timeout(1000) do
  console_log('1秒後')
end
```

### element_exists?(element)
要素が存在するかチェック

```ruby
if element_exists?(target)
  # 処理
end
```

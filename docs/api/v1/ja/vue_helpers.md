# VueHelpers API

Vue.js 3 アプリケーション構築のためのヘルパーです。

## 使用方法

```ruby
require 'opal_vite/concerns/v1/vue_helpers'

class MyVueApp
  extend VueHelpers
end
```

---

## Vue アクセス

### vue
Vue オブジェクトを取得

```ruby
vue_version = VueHelpers.vue.version
```

### create_app(options = {})
Vue アプリケーションを作成

```ruby
app = VueHelpers.create_app({
  data: `function() { return { count: 0 }; }`,
  methods: `{
    increment() { this.count++; }
  }`,
  template: '<button @click="increment">{{ count }}</button>'
})
app.mount('#app')
```

---

## リアクティブ

### vue_ref(initial_value)
リアクティブな ref を作成

```ruby
count = VueHelpers.vue_ref(0)
```

### vue_reactive(object)
リアクティブなオブジェクトを作成

```ruby
state = VueHelpers.vue_reactive({ count: 0, name: 'Vue' })
```

### vue_computed(&getter)
算出プロパティを作成

```ruby
doubled = VueHelpers.vue_computed { state.count * 2 }
```

### vue_watch(source, &callback)
リアクティブソースを監視

```ruby
VueHelpers.vue_watch(count) do |new_val, old_val|
  console_log("Changed: #{old_val} -> #{new_val}")
end
```

---

## ライフサイクルフック

### on_mounted(&block)
コンポーネントがマウントされた時

```ruby
VueHelpers.on_mounted do
  console_log('Component mounted')
end
```

### on_unmounted(&block)
コンポーネントがアンマウントされた時

```ruby
VueHelpers.on_unmounted do
  cleanup_resources
end
```

### on_updated(&block)
コンポーネントが更新された時

```ruby
VueHelpers.on_updated do
  console_log('Component updated')
end
```

### on_before_mount(&block) / on_before_unmount(&block)
マウント前/アンマウント前

```ruby
VueHelpers.on_before_mount do
  prepare_data
end
```

---

## DOM

### query(selector)
単一要素を取得

```ruby
element = VueHelpers.query('#my-element')
```

### query_all(selector)
全要素を取得

```ruby
items = VueHelpers.query_all('.item')
```

### get_element_by_id(id)
ID で要素を取得

```ruby
element = VueHelpers.get_element_by_id('app')
```

### on_dom_ready(&block)
DOM 準備完了時に実行

```ruby
VueHelpers.on_dom_ready do
  init_app
end
```

---

## タイマー

### set_timeout(delay_ms, &block)
遅延実行

```ruby
VueHelpers.set_timeout(1000) do
  console_log('1秒後')
end
```

### set_interval(interval_ms, &block)
繰り返し実行

```ruby
timer = VueHelpers.set_interval(5000) do
  fetch_updates
end
```

### clear_timeout(id) / clear_interval(id)
タイマーをクリア

```ruby
VueHelpers.clear_interval(timer)
```

---

## LocalStorage

### storage_get(key) / storage_set(key, value)
LocalStorage の操作

```ruby
VueHelpers.storage_set('theme', 'dark')
theme = VueHelpers.storage_get('theme')
```

### storage_remove(key)
キーを削除

```ruby
VueHelpers.storage_remove('temp')
```

---

## JSON

### parse_json(json_string)
JSON をパース

```ruby
data = VueHelpers.parse_json('{"key": "value"}')
```

### to_json_string(object)
JSON 文字列に変換

```ruby
json = VueHelpers.to_json_string({ key: 'value' })
```

---

## コンソール

### console_log(*args) / console_warn(*args) / console_error(*args)
コンソール出力

```ruby
VueHelpers.console_log('Debug:', data)
```

---

## グローバル

### window_get(key) / window_set(key, value)
window プロパティの取得/設定

```ruby
VueHelpers.window_set('myGlobal', value)
value = VueHelpers.window_get('myGlobal')
```

---

## 型変換

### parse_int(value, radix = 10) / parse_float(value)
数値パース

```ruby
num = VueHelpers.parse_int('42')
float = VueHelpers.parse_float('3.14')
```

### is_nan?(value)
NaN チェック

```ruby
if VueHelpers.is_nan?(result)
  console_log('Invalid number')
end
```

---

## 使用例

```ruby
require 'opal_vite/concerns/v1/vue_helpers'

class CounterApp
  extend VueHelpers

  TEMPLATE = <<~HTML
    <div>
      <p>Count: {{ count }}</p>
      <button @click="increment">+</button>
      <button @click="decrement">-</button>
    </div>
  HTML

  def self.create_app
    options = {
      data: `function() { return { count: 0 }; }`,
      methods: `{
        increment() { this.count++; },
        decrement() { this.count--; }
      }`,
      template: TEMPLATE,
      mounted: `function() {
        console.log('Counter mounted');
      }`
    }

    VueHelpers.create_app(options)
  end

  def self.mount(selector)
    app = create_app
    app.mount(selector)
    console_log("CounterApp mounted to #{selector}")
  end
end

# 使用
VueHelpers.on_dom_ready do
  CounterApp.mount('#app')
end
```

# OpalVite Concerns API v1

OpalVite Concerns は、Opal + Vite プロジェクトで JavaScript との連携を容易にするヘルパーモジュール群です。

## インストール

```ruby
# 全モジュールを読み込む
require 'opal_vite/concerns/v1'

# または個別に読み込む
require 'opal_vite/concerns/v1/stimulus_helpers'
require 'opal_vite/concerns/v1/dom_helpers'
```

## モジュール一覧

| モジュール | 説明 | 主な用途 |
|-----------|------|---------|
| [StimulusHelpers](stimulus_helpers.md) | Stimulus コントローラ用ヘルパー | ターゲット操作、イベント処理、DOM操作 |
| [DomHelpers](dom_helpers.md) | DOM 操作ヘルパー | 要素操作、イベント発火、スタイル変更 |
| [JsProxyEx](js_proxy_ex.md) | JavaScript オブジェクトラッパー | JS オブジェクトへの Ruby 風アクセス |
| [Storable](storable.md) | LocalStorage ヘルパー | データの永続化 |
| [Toastable](toastable.md) | Toast 通知ヘルパー | ユーザー通知 |
| [VueHelpers](vue_helpers.md) | Vue.js 3 ヘルパー | Vue アプリケーション構築 |
| [ReactHelpers](react_helpers.md) | React ヘルパー | React アプリケーション構築 |

## 使用例

### Stimulus コントローラでの使用

```ruby
require 'opal_vite/concerns/v1/stimulus_helpers'

class TodoController < StimulusController
  include OpalVite::Concerns::StimulusHelpers

  def add_todo
    text = target_value(:input)
    return if text.to_s.strip.empty?

    target_set_html(:list, target_html(:list) + "<li>#{text}</li>")
    target_clear(:input)
    storage_set_json('todos', get_todos)
  end

  def toggle_theme
    toggle_target_class(:container, 'dark')
  end
end
```

### Vue.js での使用

```ruby
require 'opal_vite/concerns/v1/vue_helpers'

class CounterApp
  extend VueHelpers

  def self.create_app
    options = {
      data: `function() { return { count: 0 }; }`,
      methods: `{
        increment() { this.count++; },
        decrement() { this.count--; }
      }`,
      template: '<div>{{ count }}</div>'
    }
    VueHelpers.create_app(options)
  end
end
```

## 後方互換性

v0.2.8 より、ヘルパーはバージョン付きパス（`v1/`）に移動しました。
旧パスは引き続き動作しますが、コンソールに非推奨警告が表示されます。

```ruby
# 旧（非推奨、警告が出る）
require 'opal_vite/concerns/stimulus_helpers'

# 新（推奨）
require 'opal_vite/concerns/v1/stimulus_helpers'
```

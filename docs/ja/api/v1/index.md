# OpalVite Helpers API v1

OpalVite Concerns v1のAPIドキュメントです。

## モジュール構造

すべてのヘルパーは `OpalVite::Concerns::V1` 名前空間に配置されています：

```ruby
require 'opal_vite/concerns/v1/stimulus_helpers'

class MyController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers
end
```

## 利用可能なモジュール

| モジュール | 説明 |
|-----------|------|
| [StimulusHelpers](/api/v1/ja/stimulus_helpers.md) | Stimulusコントローラー連携 |
| [DomHelpers](/api/v1/ja/dom_helpers.md) | DOM操作ユーティリティ |
| [Storable](/api/v1/ja/storable.md) | LocalStorage永続化 |
| [Toastable](/api/v1/ja/toastable.md) | トースト通知システム |
| [JsProxyEx](/api/v1/ja/js_proxy_ex.md) | JavaScriptオブジェクトラッパー |
| [VueHelpers](/api/v1/ja/vue_helpers.md) | Vue.js 3連携 |
| [ReactHelpers](/api/v1/ja/react_helpers.md) | React連携 |

## 後方互換性

後方互換性のため、旧パスも引き続き使用できます：

```ruby
require 'opal_vite/concerns/stimulus_helpers'
include OpalVite::Concerns::StimulusHelpers
```

ただし、非推奨警告が表示されます。v1パスへの移行を推奨します。

## グローバルエイリアス

利便性のため、トップレベルのエイリアスも利用できます：

```ruby
require 'opal_vite/concerns/v1/stimulus_helpers'
include StimulusHelpers  # OpalVite::Concerns::V1::StimulusHelpers と同じ
```

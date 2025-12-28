# サンプルアプリケーション

opal-viteには、Stimulus APIの様々な機能をデモンストレーションするサンプルアプリケーションが含まれています。

## Counter App

[ライブデモ](/playground/counter-app/) | [ソースコード](https://github.com/stofu1234/opal-vite/tree/master/examples/counter-app)

**Stimulus Values API**を使用したシンプルなカウンターアプリケーション。

**デモンストレーションする機能:**
- `stimulus_value(:name)` - 値の取得
- `set_stimulus_value(:name, value)` - 値の設定
- `increment_stimulus_value(:name)` - 数値のインクリメント
- `decrement_stimulus_value(:name)` - 数値のデクリメント
- 値変更コールバック (`count_value_changed`)

**ディレクトリ:** `examples/counter-app/`

```ruby
class CounterController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  self.values = { count: :number }
  self.targets = ["display"]

  def connect
    update_display
  end

  def increment
    increment_stimulus_value(:count)
  end

  def decrement
    decrement_stimulus_value(:count)
  end

  def reset
    set_stimulus_value(:count, 0)
  end

  def count_value_changed
    update_display
  end

  private

  def update_display
    target_set_text(:display, stimulus_value(:count).to_s)
  end
end
```

**ローカルで実行:**
```bash
cd examples/counter-app
bundle install
pnpm install
pnpm dev
```

---

## CRUD App

[ライブデモ](/playground/crud-app/) | [ソースコード](https://github.com/stofu1234/opal-vite/tree/master/examples/crud-app)

**Stimulus Action Parameters**を使用したCRUD（作成・読取・更新・削除）アプリケーション。

**デモンストレーションする機能:**
- `action_param(:name)` - アクションパラメータの取得
- `action_param_int(:id)` - 整数パラメータの取得
- `has_action_param?(:name)` - パラメータ存在チェック
- `data-[controller]-[name]-param` HTML属性構文
- イベント通信を使ったモーダルダイアログ

**ディレクトリ:** `examples/crud-app/`

```ruby
class ListController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  self.targets = ["container", "template", "nameInput"]
  self.values = { items: :array }

  def edit
    # data-list-id-param, data-list-name-param属性からパラメータを取得
    id = action_param_int(:id)
    name = action_param(:name)
    quantity = action_param_int(:quantity, 1) if has_action_param?(:quantity)

    dispatch_window_event('open-modal', { id: id, name: name, quantity: quantity })
  end

  def delete
    id = action_param_int(:id)
    # ... 削除ロジック
  end
end
```

**アクションパラメータを使ったHTML:**
```html
<button data-action="click->list#edit"
        data-list-id-param="123"
        data-list-name-param="アイテム名"
        data-list-quantity-param="5">
  編集
</button>
```

**ローカルで実行:**
```bash
cd examples/crud-app
bundle install
pnpm install
pnpm dev
```

---

## Tabs App

[ライブデモ](/playground/tabs-app/) | [ソースコード](https://github.com/stofu1234/opal-vite/tree/master/examples/tabs-app)

**Stimulus OutletsとDispatch**を使用したタブインターフェース。

**デモンストレーションする機能:**
- アウトレット接続 (`self.outlets = ["panel"]`)
- `has_outlet?(:name)` - アウトレット存在チェック
- `call_outlet(:name, :method)` - アウトレットのメソッド呼び出し
- `call_all_outlets(:name, :method)` - 全アウトレットのメソッド呼び出し
- `dispatch_window_event(name, detail)` - カスタムイベントのディスパッチ
- `on_window_event(name)` - ウィンドウイベントのリッスン

**ディレクトリ:** `examples/tabs-app/`

```ruby
# タブコントローラー
class TabsController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  self.targets = ["tab"]
  self.outlets = ["panel"]

  def select
    index = action_param_int(:index)
    activate_tab(index)
    show_panel_by_index(index)
  end

  private

  def show_panel_by_index(index)
    # アウトレット経由で全パネルを非表示
    call_all_outlets(:panel, :hide) if has_outlet?(:panel)
    # パネル表示用のイベントをディスパッチ
    dispatch_window_event('tabs:change', { index: index })
  end
end

# パネルコントローラー
class PanelController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  def connect
    on_window_event('tabs:change') do |event|
      detail = `#{event}.detail`
      index = `#{detail}.index`
      my_index = action_param_int(:index)
      index == my_index ? show : hide
    end
  end

  def show
    element_remove_class('panel-hidden')
  end

  def hide
    element_add_class('panel-hidden')
  end
end
```

**ローカルで実行:**
```bash
cd examples/tabs-app
bundle install
pnpm install
pnpm dev
```

---

## テストの実行

各サンプルアプリにはCapybara + Cupriteを使ったE2Eテストが含まれています:

```bash
cd examples/counter-app
pnpm dev &
bundle exec rspec
```

## 本番ビルド

全てのサンプルアプリは本番ビルドをサポートしています:

```bash
cd examples/counter-app
pnpm build    # 本番用ビルド
pnpm preview  # 本番ビルドのプレビュー
```

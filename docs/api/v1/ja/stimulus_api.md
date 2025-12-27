# Stimulus API ヘルパー

v0.3.0の新機能: Values、CSS Classes、Outlets、dispatch()、Action Parametersなど、StimulusのコアAPIを完全サポート。

## Values API

`self.values = { name: :type }` で定義されたStimulus Valuesにアクセス。

```ruby
class CounterController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  # Ruby DSLでValuesを定義
  self.values = { count: :number, label: :string }

  def increment
    increment_value(:count)      # 1増加
    increment_value(:count, 5)   # 5増加
  end

  def decrement
    decrement_value(:count)
  end

  def reset
    set_value(:count, 0)
  end

  def display
    count = get_value(:count)
    label = get_value(:label)
    target_set_text(:output, "#{label}: #{count}")
  end

  def toggle_feature
    toggle_value(:enabled)  # ブール値を反転
  end

  def conditional_load
    if has_value?(:api_url)
      fetch_json(get_value(:api_url)) { |data| process(data) }
    end
  end
end
```

### メソッド

| メソッド | 説明 |
|----------|------|
| `get_value(name)` | 値を取得 |
| `set_value(name, value)` | 値を設定 |
| `has_value?(name)` | 値のdata属性が存在するか確認 |
| `increment_value(name, amount=1)` | 数値を増加 |
| `decrement_value(name, amount=1)` | 数値を減少 |
| `toggle_value(name)` | ブール値を反転 |

---

## CSS Classes API

`self.classes = [ "loading", "active" ]` で定義されたCSSクラスにアクセス。

```ruby
class FormController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  # Ruby DSLでCSSクラスを定義
  self.classes = ["loading", "success", "error"]

  def submit
    apply_class(this_element, :loading)

    fetch_json('/api/submit') do |response|
      remove_applied_class(this_element, :loading)

      if response['success']
        apply_class(this_element, :success)
      else
        apply_class(this_element, :error)
      end
    end
  end
end
```

```html
<form data-controller="form"
      data-form-loading-class="opacity-50 cursor-wait"
      data-form-success-class="border-green-500"
      data-form-error-class="border-red-500 shake">
</form>
```

### メソッド

| メソッド | 説明 |
|----------|------|
| `get_class(name)` | 単一のCSSクラス名を取得 |
| `get_classes(name)` | CSSクラス名の配列を取得 |
| `has_class_definition?(name)` | クラスが定義されているか確認 |
| `apply_class(element, name)` | 要素にCSSクラスを追加 |
| `apply_classes(element, name)` | 要素にすべてのCSSクラスを追加 |
| `remove_applied_class(element, name)` | 要素からCSSクラスを削除 |
| `remove_applied_classes(element, name)` | 要素からすべてのCSSクラスを削除 |

---

## Outlets API

`self.outlets = [ "result" ]` で定義されたOutletsにアクセス。

```ruby
class TabsController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  # Ruby DSLでOutletsを定義
  self.outlets = ["panel"]

  def select
    tab_id = action_param(:id)

    # すべてのパネルを非表示
    call_all_outlets(:panel, 'hide')

    # 選択されたパネルを表示
    get_outlets(:panel).each do |panel|
      if js_get(panel, 'idValue') == tab_id
        js_call_on(panel, 'show')
      end
    end
  end

  def connect
    return unless has_outlet?(:panel)

    # 最初のパネルをアクティブに
    first_panel = get_outlet(:panel)
    js_call_on(first_panel, 'show')
  end
end
```

### メソッド

| メソッド | 説明 |
|----------|------|
| `has_outlet?(name)` | Outletが存在するか確認 |
| `get_outlet(name)` | 単一のOutletコントローラーを取得 |
| `get_outlets(name)` | すべてのOutletコントローラーを取得 |
| `get_outlet_element(name)` | Outletの要素を取得 |
| `get_outlet_elements(name)` | すべてのOutlet要素を取得 |
| `call_outlet(name, method, *args)` | Outletのメソッドを呼び出し |
| `call_all_outlets(name, method, *args)` | すべてのOutletのメソッドを呼び出し |

---

## dispatch() API

コントローラー識別子をプレフィックスとしたカスタムイベントを発火。

```ruby
class ClipboardController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  def copy
    content = target_value(:source)

    # "clipboard:copied" イベントを発火
    stimulus_dispatch("copied", detail: { content: content })
  end

  def copy_with_confirm
    # リスナーがイベントをキャンセルしたか確認
    if stimulus_dispatch_confirm("beforeCopy")
      do_copy
    end
  end
end
```

```html
<!-- プレフィックス付きイベントをリッスン -->
<div data-action="clipboard:copied->notification#show">
  <div data-controller="clipboard">
    <button data-action="clipboard#copy">コピー</button>
  </div>
</div>
```

### メソッド

| メソッド | 説明 |
|----------|------|
| `stimulus_dispatch(name, detail:, target:, prefix:, bubbles:, cancelable:)` | プレフィックス付きイベントを発火 |
| `stimulus_dispatch_confirm(name, detail:)` | 発火してキャンセルされたか確認 |

---

## Action Parameters API

`data-[controller]-[name]-param` 属性からパラメータにアクセス。

```ruby
class ItemController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  def edit
    id = action_param_int(:id)        # 整数として自動パース
    name = action_param(:name)         # 文字列

    open_editor(id, name)
  end

  def delete
    return unless has_action_param?(:id)

    id = action_param_int(:id)
    confirmed = action_param_bool(:confirm)

    if confirmed || confirm_delete
      remove_item(id)
    end
  end
end
```

```html
<button data-action="item#edit"
        data-item-id-param="123"
        data-item-name-param="アイテム名">
  編集
</button>

<button data-action="item#delete"
        data-item-id-param="123"
        data-item-confirm-param="true">
  削除
</button>
```

### メソッド

| メソッド | 説明 |
|----------|------|
| `action_params` | すべてのパラメータをオブジェクトとして取得 |
| `action_param(name)` | パラメータ値を取得 |
| `action_param_int(name, default=0)` | 整数として取得 |
| `action_param_bool(name)` | ブール値として取得 |
| `has_action_param?(name)` | パラメータが存在するか確認 |

---

## Controller Access

コントローラーのプロパティや他のコントローラーにアクセス。

```ruby
class ModalController < StimulusController
  include OpalVite::Concerns::V1::StimulusHelpers

  def open
    # コントローラーのプロパティにアクセス
    console_log("モーダルを開く:", this_identifier)

    # 親コントローラーを取得
    parent = parent(this_element)
    form_controller = get_controller(parent, "form")

    if form_controller
      js_call_on(form_controller, 'validate')
    end
  end
end
```

### メソッド

| メソッド | 説明 |
|----------|------|
| `this_application` | Stimulus Applicationを取得 |
| `this_identifier` | コントローラー識別子を取得 |
| `this_element` | コントローラー要素を取得 |
| `this_scope` | コントローラーのスコープ要素を取得 |
| `get_controller(element, identifier)` | コントローラーインスタンスを取得 |
| `get_controllers(element, identifier)` | すべてのコントローラーを取得 |
| `in_scope?(element)` | 要素がスコープ内にあるか確認 |

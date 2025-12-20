# Toastable API

Toast 通知を表示するためのヘルパーです。

## 使用方法

```ruby
require 'opal_vite/concerns/v1/toastable'

class MyController < StimulusController
  include OpalVite::Concerns::Toastable
end
```

---

## メソッド

### dispatch_toast(message, type = 'info')
Toast 通知を発火

```ruby
dispatch_toast('操作が完了しました', 'success')
dispatch_toast('エラーが発生しました', 'error')
```

### show_success(message)
成功通知（緑）

```ruby
show_success('保存しました')
```

### show_error(message)
エラー通知（赤）

```ruby
show_error('保存に失敗しました')
```

### show_warning(message)
警告通知（黄）

```ruby
show_warning('入力内容を確認してください')
```

### show_info(message)
情報通知（青）

```ruby
show_info('新しいメッセージがあります')
```

---

## Toast コントローラ側の実装

Toast を表示するには、`show-toast` イベントをリッスンする Toast コントローラが必要です：

```ruby
class ToastController < StimulusController
  def connect
    on_window_event('show-toast') do |event|
      detail = event.detail
      show_toast(detail.message, detail.type)
    end
  end

  def show_toast(message, type)
    # Toast 表示ロジック
  end
end
```

---

## 使用例

```ruby
class FormController < StimulusController
  include OpalVite::Concerns::Toastable
  include OpalVite::Concerns::StimulusHelpers

  def submit
    if valid?
      save_data
      show_success('フォームを送信しました')
    else
      show_error('入力内容に誤りがあります')
    end
  end
end
```

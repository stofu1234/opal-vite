# Stimulus Controller Pattern: JavaScript Functions vs Ruby Methods

## 概要

このドキュメントでは、Opal-Viteプロジェクトにおいて、StimulusコントローラーでRubyメソッドからJavaScript関数への置き換えを行った理由と、そのパターンについて説明します。

## 問題の背景

### 発生した問題

以下の3つのサンプルアプリケーションで、同様のエラーが発生しました：

1. **form-validation-app**
2. **i18n-app**
3. **pwa-app**

#### 主なエラーメッセージ

```javascript
// エラー例1: メソッドが見つからない
TypeError: ctrl.updateStats is not a function

// エラー例2: Stimulusアクションメソッドが未定義
Error: Action "click->i18n#switchLanguage" references undefined method "switchLanguage"

// エラー例3: 変数の重複宣言
SyntaxError: Identifier 'forms' has already been declared
```

### 問題の原因

#### 1. イベントパラメータのラッピング問題

Opalコンパイラは、Rubyメソッドのパラメータを特殊な方法で処理します。JavaScriptの`event`オブジェクトがOpalによってラップされるため、直接アクセスできない場合がありました。

**問題のあるコード例:**

```ruby
def validate_field(event)
  `
    const field = event.target;  // eventがラップされているため動作しない
  `
end
```

#### 2. メソッド名の変換問題

Rubyのスネークケース（`snake_case`）とJavaScriptのキャメルケース（`camelCase`）の変換において、Stimulusのアクション定義と実際のメソッド名が一致しない問題が発生しました。

**問題のあるコード例:**

```ruby
# HTML側
<button data-action="click->i18n#switchLanguage">

# Ruby側
def switch_language(event)  # snake_case
  # ...
end

# Stimulusは switchLanguage を探すが、
# Opalは switch_language として登録するため見つからない
```

#### 3. メソッド呼び出しの問題

`connect()`メソッド内のJavaScriptコードから、別のRubyメソッドを呼び出す際、正しいプレフィックス（`$`）とメソッド名（スネークケース）を使用する必要がありました。

**問題のあるコード例:**

```ruby
def connect
  `
    ctrl.updateTranslations();  // ✗ 動作しない
    ctrl.$update_translations(); // ✓ 正しい呼び出し方
  `
end

def update_translations
  # ...
end
```

#### 4. 変数の重複宣言

Rubyメソッドのパラメータと、バッククォート内のJavaScript変数宣言が競合しました。

**問題のあるコード例:**

```ruby
def pluralize(forms, count)  # Rubyパラメータ
  `
    const forms = arguments[0];  // JavaScriptで再宣言 → エラー!
    const count = arguments[1];
  `
end
```

## 解決策: JavaScript関数への統一

### アプローチ

すべてのメソッドロジックを`connect()`メソッド内でJavaScript関数として定義することで、上記の問題をすべて解決しました。

### 実装パターン

#### パターン1: ヘルパー関数

内部的に使用する関数は`ctrl.functionName`として定義します。

```ruby
def connect
  `
    const ctrl = this;

    // ヘルパー関数の定義
    ctrl.updateStats = function() {
      const total = ctrl.fieldTargets.length;
      // ... 処理
    };

    ctrl.formatCurrency = function(amount) {
      return new Intl.NumberFormat(ctrl.currentLocaleValue, {
        style: 'currency',
        currency: 'USD'
      }).format(amount);
    };
  `
end
```

#### パターン2: Stimulusアクションメソッド

Stimulusから呼び出されるアクションメソッドは`this.methodName`として定義します。

```ruby
def connect
  `
    const ctrl = this;

    // Stimulusアクションメソッド（キャメルケース）
    this.switchLanguage = function(event) {
      const locale = event.currentTarget.dataset.locale;
      ctrl.currentLocaleValue = locale;
      ctrl.updateTranslations();
    };

    this.handleSubmit = function(event) {
      event.preventDefault();
      // フォーム送信処理
    };
  `
end
```

#### パターン3: 初期化処理

`connect()`メソッドの最後で、初期化処理を実行します。

```ruby
def connect
  `
    const ctrl = this;

    // 関数定義...

    // 初期化
    ctrl.loadData();
    ctrl.updateDisplay();
  `
end
```

## 修正前後の比較

### Before（修正前）

```ruby
class I18nController < StimulusController
  def connect
    `
      const ctrl = this;
      ctrl.updateTranslations();  // ✗ エラー: メソッドが見つからない
    `
  end

  def switch_language(event)  # ✗ Stimulusが見つけられない
    `
      const locale = event.currentTarget.dataset.locale;  # ✗ eventラッピング問題
      // ...
    `
  end

  def update_translations
    `
      const ctrl = this;
      // ...
    `
  end

  def pluralize(forms, count)
    `
      const forms = arguments[0];  # ✗ 重複宣言エラー
      const count = arguments[1];
      // ...
    `
  end
end
```

### After（修正後）

```ruby
class I18nController < StimulusController
  def connect
    `
      const ctrl = this;

      // ヘルパー関数
      ctrl.pluralize = function(forms, count) {
        let key = 'other';
        if (count === 0) key = 'zero';
        else if (count === 1) key = 'one';
        return forms[key].replace('{count}', count);
      };

      ctrl.updateTranslations = function() {
        const t = ctrl.translations[ctrl.currentLocaleValue];
        // ... UI更新処理
      };

      // Stimulusアクションメソッド
      this.switchLanguage = function(event) {
        const locale = event.currentTarget.dataset.locale;
        ctrl.currentLocaleValue = locale;
        ctrl.updateTranslations();
      };

      // 初期化
      ctrl.updateTranslations();
    `
  end
end
```

## メリット

### 1. ブラウザエラーの完全解消

- すべてのメソッド呼び出しエラーが解消
- Stimulusアクションが正しく動作
- 変数の重複宣言エラーがなくなる

### 2. コードの明確性向上

- すべてのロジックが`connect()`メソッド内に集約
- JavaScript関数として直接定義されるため、動作が明確
- イベントパラメータの扱いが簡潔

### 3. メンテナンス性の向上

- Ruby/JavaScript間の変換問題を回避
- 一貫したパターンで実装可能
- デバッグが容易

### 4. パフォーマンス

- Opalのメソッド呼び出しオーバーヘッドがない
- 直接的なJavaScript実行

## 適用したアプリケーション

このパターンは以下の3つのサンプルアプリケーションで適用され、すべてのブラウザエラーが解消されました：

### 1. form-validation-app

**修正したメソッド:**
- `validate_field` → `this.validate_field`
- `clear_error` → `this.clear_error`
- `handle_submit` → `this.handle_submit`
- `reset_form` → `this.reset_form`
- `update_stats` → `ctrl.updateStats`
- `show_field_error` → `ctrl.showFieldError`
- その他ヘルパー関数

**結果:**
- リアルタイムバリデーション動作 ✓
- フォーム送信機能動作 ✓
- 統計表示更新動作 ✓

### 2. i18n-app

**修正したメソッド:**
- `switch_language` → `this.switchLanguage`
- `handle_submit` → `this.handleSubmit`
- `update_translations` → `ctrl.updateTranslations`
- `pluralize` → `ctrl.pluralize`
- `format_currency` → `ctrl.formatCurrency`
- `format_date` → `ctrl.formatDate`
- `format_time` → `ctrl.formatTime`

**結果:**
- 5言語切り替え動作 ✓（EN, JA, ES, FR, DE）
- 動的翻訳更新 ✓
- ロケール別フォーマット ✓

### 3. pwa-app

**修正したコントローラー:**

#### PwaController
- `install` → `this.install`
- `dismiss_install_prompt` → `this.dismissInstallPrompt`
- `add_note` → `this.addNote`
- `delete_note` → `this.deleteNote`
- `update_cache` → `this.updateCache`
- `clear_cache` → `this.clearCache`
- その他12のヘルパー関数

#### OfflineDetectorController
- `update_status` → `ctrl.updateStatus`

**結果:**
- PWAインストール機能動作 ✓
- オフラインノート機能動作 ✓
- キャッシュ管理動作 ✓
- オンライン/オフライン検出動作 ✓

## ベストプラクティス

### 1. 一貫したパターンの使用

すべてのStimulusコントローラーで同じパターンを使用します：

```ruby
class MyController < StimulusController
  def connect
    `
      const ctrl = this;

      // 1. ヘルパー関数定義
      ctrl.helperFunction = function() { /* ... */ };

      // 2. Stimulusアクションメソッド定義
      this.actionMethod = function(event) { /* ... */ };

      // 3. 初期化処理
      ctrl.initialize();
    `
  end
end
```

### 2. 命名規則

- **ヘルパー関数**: キャメルケース、`ctrl.`プレフィックス
  - 例: `ctrl.updateDisplay()`, `ctrl.formatData()`

- **Stimulusアクション**: キャメルケース、`this.`プレフィックス
  - 例: `this.handleClick()`, `this.submitForm()`

### 3. イベント処理

イベントパラメータを直接使用できます：

```ruby
this.handleClick = function(event) {
  event.preventDefault();
  const target = event.currentTarget;
  const value = target.dataset.value;
  // ...
};
```

### 4. Stimulus Targets/Values の使用

Stimulusの機能は通常通り使用できます：

```ruby
`
  const ctrl = this;

  if (ctrl.hasMyTarget) {
    ctrl.myTarget.textContent = 'Updated';
  }

  ctrl.myValueValue = 'new value';
`
```

## トラブルシューティング

### よくある問題と解決策

#### 問題1: "Method is not a function"

**原因**: メソッドが関数として定義されていない

**解決策**:
```ruby
# ✗ 間違い
def connect
  `ctrl.myMethod();`
end

def my_method
  `console.log('test');`
end

# ✓ 正しい
def connect
  `
    const ctrl = this;
    ctrl.myMethod = function() {
      console.log('test');
    };
    ctrl.myMethod();
  `
end
```

#### 問題2: "Undefined method" for Stimulus action

**原因**: アクションメソッドが`this.`で定義されていない

**解決策**:
```ruby
# HTML: data-action="click->my#doSomething"

# ✓ 正しい
this.doSomething = function(event) {
  // キャメルケースで定義
};
```

#### 問題3: Targetsにアクセスできない

**原因**: `ctrl`参照を使用していない

**解決策**:
```ruby
`
  const ctrl = this;

  // ✓ 正しい
  ctrl.myTarget.textContent = 'text';

  // 関数内でも ctrl を使用
  ctrl.updateDisplay = function() {
    ctrl.myTarget.textContent = 'updated';
  };
`
```

## 結論

JavaScript関数への統一は、以下の理由から推奨されるパターンです：

1. **互換性**: OpalとStimulusの統合における問題を完全に解消
2. **明確性**: すべてのロジックが一箇所に集約され、理解しやすい
3. **保守性**: 一貫したパターンでメンテナンスが容易
4. **信頼性**: ブラウザエラーがなく、安定して動作

このパターンは、Opal + Stimulus環境における**ベストプラクティス**として採用すべきです。

## 参考リンク

- [Stimulus Handbook](https://stimulus.hotwired.dev/handbook/introduction)
- [Opal Documentation](https://opalrb.com/)
- [opal_stimulus gem](https://github.com/your-repo/opal_stimulus)

---

**ドキュメント作成日**: 2025-12-15
**対象バージョン**: Opal-Vite v1.0.0

# Practical App E2E Tests

RubyユーザーフレンドリーなCapybara + Cupriteを使用したE2Eテストです。

## 必要条件

- Ruby 3.0以上
- Bundler
- Chrome/Chromium（Cupriteが自動検出）

## インストール

```bash
# Gem依存関係をインストール
bundle install

# Node依存関係をインストール（Vite用）
pnpm install
```

## テストの実行

### 全テスト実行

```bash
# Vite開発サーバーを起動（別ターミナル）
pnpm dev

# テスト実行
pnpm test
# または
bundle exec rspec
```

### ブラウザ表示モード

```bash
HEADLESS=false bundle exec rspec
# または
pnpm test:headed
```

### スローモーション（デバッグ用）

```bash
HEADLESS=false SLOWMO=0.5 bundle exec rspec
# または
pnpm test:slowmo
```

### 特定のテストファイルを実行

```bash
bundle exec rspec spec/features/todo_spec.rb
```

### 特定のテストを実行

```bash
bundle exec rspec spec/features/todo_spec.rb:15
```

## テスト構成

```
spec/
├── features/
│   ├── todo_spec.rb      # Todo機能テスト
│   ├── theme_spec.rb     # ダークモード切替テスト
│   └── modal_spec.rb     # モーダル操作テスト
├── support/
├── spec_helper.rb        # RSpec + Capybara設定
└── README.md
```

## テストカバレッジ

### Todoテスト (`todo_spec.rb`)
- ✅ 新しいTodoを追加
- ✅ Todoの完了状態を切替
- ✅ Todoを削除
- ✅ Todoをフィルター（全て/アクティブ/完了済）
- ✅ localStorageへの永続化
- ✅ カウント更新
- ✅ 空のTodoを防止
- ✅ 完了済Todoをクリア

### テーマテスト (`theme_spec.rb`)
- ✅ ライト/ダークモードの切替
- ✅ テーマ設定の永続化
- ✅ ボタン表示の更新
- ✅ テーマスタイルの適用

### モーダルテスト (`modal_spec.rb`)
- ✅ モーダルを開く
- ✅ 閉じるボタンで閉じる
- ✅ キャンセルボタンで閉じる
- ✅ Escapeキーで閉じる
- ✅ モーダル表示中のスクロール防止
- ✅ モーダル閉じた後のスクロール復帰
- ✅ モーダル内のフォーカス管理
- ✅ 変更の保存

## 新しいテストの書き方

```ruby
# spec/features/my_feature_spec.rb
RSpec.describe 'My Feature', type: :feature do
  it 'does something' do
    visit '/'

    # 要素を操作
    fill_in 'input-name', with: 'value'
    click_button 'Submit'

    # アサーション
    expect(page).to have_content('Success')
  end
end
```

## ベストプラクティス

### 1. data属性をセレクターに使用

```ruby
# Good
find('[data-todo-target="input"]').set('...')

# Avoid
find('.todo-input').set('...')
```

### 2. Capybaraの自動待機を活用

```ruby
# Good - 自動待機する
expect(page).to have_content('Success')

# Avoid - 固定待機
sleep 1
```

### 3. JSエラー検出

Cupriteの `js_errors: true` オプションにより、JavaScriptエラーが発生すると
テストが自動的に失敗します。

### 4. テストは独立させる

各テストは `before(:each)` で `localStorage.clear()` を実行して
クリーンな状態から開始します。

## CI/CD統合

GitHub Actionsでの実行例:

```yaml
- name: Run E2E tests
  run: |
    cd examples/practical-app
    pnpm dev &
    sleep 5
    bundle exec rspec
  env:
    CI: true
```

## リソース

- [Capybara Documentation](https://github.com/teamcapybara/capybara)
- [Cuprite - Headless Chrome driver](https://github.com/rubycdp/cuprite)
- [RSpec Documentation](https://rspec.info/)

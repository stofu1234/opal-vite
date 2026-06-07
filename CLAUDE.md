## プロジェクト規約・注意点

### 1. opal_stimulus gem の制限

**問題**: クラス名に数字が含まれる場合、Stimulusコントローラー名が正しく生成されない

```ruby
# 例: Base64DemoController → "base64demo" (誤) ではなく "base64-demo" (正)

# 解決策: stimulus_name を明示的にオーバーライド
class Base64DemoController < StimulusController
  def self.stimulus_name
    'base64-demo'
  end
end
```

**原因**: `opal_stimulus` の正規表現 `/([a-z])([A-Z])/` が数字→大文字の変換に対応していない

---

### 2. ファイル構成規約

```
examples/[app-name]/
├── app/opal/
│   ├── application.rb      # エントリーポイント
│   └── controllers/        # Stimulusコントローラー
├── src/
│   └── main.js             # JS エントリー（Stimulus/Opal初期化）
├── index.html
├── vite.config.ts
├── package.json
├── Gemfile                 # テスト用gem依存
└── spec/                   # Capybara E2Eテスト
    ├── spec_helper.rb
    └── features/
```

---

### 3. E2Eテスト規約

**テストフレームワーク**: Capybara + Cuprite (Headless Chrome)

```ruby
# spec_helper.rb の必須設定
require 'capybara/rspec'
require 'capybara/cuprite'
require 'opal/vite/testing/stable_helpers'

Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(app,
    window_size: [1280, 800],
    js_errors: true,
    headless: true,
    timeout: 15
  )
end

# StableHelpersを使用
config.include StableHelpers, type: :feature
```

**重要**: `wait_for_stimulus_ready` でコントローラー接続を確認してからテスト実行

---

### 4. GitHub Actions デプロイ

**deploy.yml の EXAMPLES リスト更新必須**:
```yaml
EXAMPLES="practical-app chart-app stimulus-app api-example form-validation-app i18n-app pwa-app turbo-app vue-app react-app snabberb-app counter-app crud-app tabs-app utilities-app"
```

新しいexampleアプリを追加したら、このリストにも追加すること。

---

### 5. vite.config.ts 必須設定

```typescript
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      debug: true  // 開発時はtrue
    })
  ],
  server: {
    port: 30XX  // 他のアプリと重複しないポート
  },
  base: process.env.VITE_BASE || '/'  // GitHub Pagesデプロイ用
})
```

---

### 6. OpalVite::Concerns モジュール追加手順

1. `gems/opal-vite/opal/opal_vite/concerns/v1/` に新モジュール作成
2. `gems/opal-vite/opal/opal_vite/concerns/v1.rb` でrequire追加
3. `docs/api/v1/en/` にドキュメント追加
4. サンプルアプリで使用例を追加
5. E2Eテスト作成

---

### 7. コミット規約

```bash
git commit -m "$(cat <<'EOF'
簡潔なタイトル

詳細な説明...

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

---

### 8. PR作成規約

```bash
gh pr create --title "タイトル" --body "$(cat <<'EOF'
## Summary
- 変更点1
- 変更点2

## Test plan
- [ ] テスト項目

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

### 9. Stimulus アクション名の命名規則

**重要**: `opal_stimulus` を使用する場合、HTMLの `data-action` 属性のメソッド名は **snake_case** で記述する必要がある。

```html
<!-- ❌ 誤り: camelCase -->
<button data-action="click->debug-demo#logMessage">Log</button>

<!-- ✅ 正解: snake_case -->
<button data-action="click->debug-demo#log_message">Log</button>
```

**原因**: RubyのメソッドはCamelCaseではなくsnake_caseで定義されるため、opal_stimulusはHTMLからのアクション名をそのままRubyメソッド名として使用する。

**エラー例**:
```
Action "click->debug-demo#logMessage" references undefined method "logMessage"
```

---

### 10. Opal での require vs require_relative

**重要**: Opalアプリケーションでは `require_relative` ではなく `require` を使用する。

```ruby
# ❌ 誤り: require_relative
require_relative 'controllers/demo_controller'

# ✅ 正解: require
require 'controllers/demo_controller'
```

**原因**: Opalのロードパスは `app/opal/` をルートとして設定されているため、`require` で相対パスを指定できる。`require_relative` はファイルシステムベースで解決しようとするため、Opalコンパイル時に `MissingRequire` エラーが発生する。

---

### 11. リベース時のconflict解決

masterブランチが更新された場合のリベース手順:

```bash
git fetch origin
git rebase origin/master
# コンフリクト発生時
git status  # コンフリクトファイル確認
# 手動でコンフリクト解決（両方の変更をマージ）
git add <resolved-files>
git rebase --continue
git push --force-with-lease
```

**compiler.ts の典型的なコンフリクト**:
- masterで追加された機能（ディスクキャッシュ、並列コンパイル等）
- ブランチで追加した機能（エラーハンドリング等）
- 両方のimport文と関数を保持するように手動マージする

---

## ポート番号一覧

| App | Port |
|-----|------|
| standalone | 3000 |
| stimulus-app | 3001 |
| practical-app | 3002 |
| api-example | 3004 |
| chart-app | 3005 |
| i18n-app | 3006 |
| pwa-app | 3007 |
| utilities-app | 3008 |
| form-validation-app | 3009 |
| turbo-app | 3010 |
| vue-app | 3011 |
| react-app | 3012 |
| snabberb-app | 3013 |
| counter-app | 3014 |
| crud-app | 3015 |
| tabs-app | 3016 |
| debug-app | 3017 |
| actioncable-app | 3018 |
| stimulus-components-app | 3020 |

---

## セッション開始時のチェックリスト

1. [ ] `git fetch origin && git checkout master && git pull`
2. [ ] `pnpm install`
3. [ ] 作業用ブランチ作成: `git checkout -b feature/[task-name]`
4. [ ] 関連ファイル確認
5. [ ] 既存テスト実行で環境確認

---

## 参考リンク

- Opal公式: https://opalrb.com/
- Stimulus: https://stimulus.hotwired.dev/
- Vite: https://vitejs.dev/
- opal_stimulus gem: https://rubygems.org/gems/opal_stimulus

---

*最終更新: 2025-12-30 (v0.3.4リリース後)*

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

**重要**: `before` フックで `wait_for_stimulus_ready` → `wait_for_stimulus_connected` → `wait_for_dom_stable` の順に待ってからテストを実行する

```ruby
config.before(:each, type: :feature) do
  visit '/'
  wait_for_stimulus_ready       # アプリ固有の初期化確認
  wait_for_stimulus_connected   # 全 [data-controller] の接続を確認（StableHelpers）
  wait_for_dom_stable
end
```

- 要素やターゲットが存在するかだけを確認しても準備完了にはならない（静的 HTML に最初からあり、Opal がコントローラーを登録する前でも見つかる）。flaky の原因になる
- `connect()` などで後から変わる属性は `expect(el[:class])` のように 1 回だけ読まず、`have_css('.foo.active')` のような待機付きマッチャで検証する

---

### 4. GitHub Actions デプロイ

**deploy.yml の EXAMPLES リスト更新必須**:
```yaml
EXAMPLES="practical-app chart-app stimulus-app api-example form-validation-app i18n-app pwa-app turbo-app vue-app react-app snabberb-app counter-app crud-app tabs-app utilities-app debug-app stimulus-components-app component-base-app"
```

新しいexampleアプリを追加したら、このリストにも追加すること（リストは「Build examples for playground」と「Copy examples to playground directory」の 2 箇所にある）。

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

### 12. Opal ランタイムの読み込み

コンパイルされた `.rb` モジュールは corelib を含まず、先頭で `import '/@opal-runtime'` を自動で行う（vite-plugin-opal >= 0.3.16 + opal-vite gem >= 0.3.15）。

- JS エントリで `import '/@opal-runtime'` を書く必要はない（書いても二重読み込みにはならない）
- `<script src="/@opal-runtime">` のような別 URL でランタイムを読み込まない（dev で二重に評価される）
- Rails: `opal_javascript_tag` は `vite_javascript_tag` と同じ。`opal_runtime_tag` は非推奨で何も出力しない
- コンソールに `Opal already loaded` が出たら、gem と plugin のバージョンの組み合わせを確認する

---

### 13. 複数行のバッククォート（x-string）は明示的に return する

Opal は複数行の x-string を「文」として出力し、暗黙の return を付けない。メソッドの戻り値にする場合は x-string 内で `return` を書く。

```ruby
# ❌ 誤り: function() {...} という名前なし関数の「文」になり、JS の構文エラー
def with(&block)
  `function() {
    ...
  }`
end

# ❌ これも誤り: Opal が cb = ...; cb を畳み込むので同じ結果になる
cb = `function() {
  ...
}`
cb

# ✅ 正解
def with(&block)
  `return function() {
    ...
  }`
end
```

組み込み concern は `gems/opal-vite/spec/compiler_spec.rb` でコンパイルして `node --check` にかけている（node が必要）。concern を追加・変更したら gem の spec を回すこと。

---

### 14. opal_stimulus の複数語の名前

opal_stimulus 0.2.x は `has_*_target` などの JS 名を `String#capitalize` で作るため、複数語の名前（`soundButton`、`latest_paid` など）で壊れる。互換パッチを使う。

```ruby
require 'opal_stimulus/stimulus_controller'
require 'opal_vite/compat/opal_stimulus'   # コントローラー定義より前
```

詳細は `docs/api/v1/en/opal_stimulus_compat.md`。`JS::Proxy`（opal_stimulus の `*_target` の戻り値）で存在しないプロパティを読むと `NoMethodError` になるので、任意のプロパティは `js_get` / `dataset_value`（StimulusHelpers）で読む。

---

### 15. バージョンとリリース

npm の plugin は gem の Ruby コードを呼び出すため、3 パッケージの互換を保つ。互換表は `packages/vite-plugin-opal/README.md` と `gems/opal-vite-rails/README.md` にある。

- plugin が gem に新しいキーワード引数を渡す場合は、plugin 起動時の gem 調査（`getRubyEnvironment`）で対応可否を判定し、古い gem でも壊れないようにする
- `opal-vite-rails.gemspec` の `opal-vite` 依存の下限を、必要な機能が入った版に合わせる
- 公開は手動。依存関係の順に **opal-vite gem → opal-vite-rails gem → npm** の順で行う
  - RubyGems の API キーには **Push rubygem** のスコープが必要（Show dashboard のみのキーでは "This API key cannot perform the specified action" になる）
- タグは plugin のバージョンに合わせて `v<version>` を push する（`release.yml` が GitHub Release を作成する。npm / gem の公開はしない）

---

### 16. テストの実行

| 対象 | コマンド |
|------|---------|
| vite-plugin-opal | `cd packages/vite-plugin-opal && pnpm exec vitest run`（`pnpm test -- --run` は watch モードのままになる） |
| opal-vite gem | `cd gems/opal-vite && bundle exec rspec`（CI の Test Vite Plugin ジョブでも実行） |
| example の E2E | 該当 example で `pnpm dev` を起動してから `bundle exec rspec`（spec_helper の `app_host` のポートで待ち受けること） |

- `examples/chat-app/dist` はコミットされているので、chat-app で `pnpm build` した後は `git checkout -- examples/chat-app/dist` で戻す
- ディスクキャッシュ（`node_modules/.cache/opal-vite`）はオプションや gem バージョンが変わると自動で無効になるが、`path:` 指定の gem のソースを編集した場合は手動で削除する

---

### 17. Rails 連携（opal-vite-rails / examples/rails-app）

- Opal のソースは vite_ruby の `sourceCodeDir`（既定 `app/frontend`）配下の `opal/` に置き、`entrypoints/*.js` から import する。`entrypoints` から import されない `.rb` はバンドルに入らない
- engine が `config.opal_vite.source_path`（既定 `app/opal`）と `<sourceCodeDir>/opal` を Zeitwerk の対象外にする。これが無いと本番の eager load で MRI が Opal コードを読み込み LoadError になる
- ジェネレータは `rails g opal_vite:install`
- `examples/rails-app` は `public/vite`（本番ビルド）をコミットしており、Docker イメージ（Railway も Dockerfile でビルド）はそれを配信するだけで Node を使わない。`app/frontend` を変更したら `RAILS_ENV=production bin/vite build` で再ビルドしてコミットする

---

### 18. HTML に値を入れるとき・document へのリスナー

- `set_html` / `target_set_html` / OpalComponent の `render` は文字列を HTML として解釈する。ユーザー入力・URL・サーバーから来た値は `escape_html`（StimulusHelpers / OpalComponent）を通すか、`set_text` / `target_set_text` を使う
- `on_turbo` など document に付けるリスナーはコントローラーより長生きする。`disconnect` で `off_all_turbo` を呼ぶ

---

## ポート番号一覧

`vite.config.ts` の `server.port` の実際の値。E2E の `spec/spec_helper.rb` の `app_host` もこのポートを前提にしているため、変更する場合は両方を直す。**重複しているアプリは同時に起動できない**。

| App | Port | 備考 |
|-----|------|------|
| counter-app | 3000 | 重複 |
| inesita-app | 3000 | 重複 |
| standalone | 3000 | 重複 |
| stimulus-app | 3000 | 重複 |
| practical-app | 3001 | 重複 |
| turbo-app | 3001 | 重複 |
| api-example | 3004 | |
| crud-app | 3005 | |
| chat-app | 3006 | |
| tabs-app | 3007 | |
| chart-app | 3008 | 重複 |
| utilities-app | 3008 | 重複 |
| vue-app | 3010 | |
| form-validation-app | 3011 | |
| i18n-app | 3012 | |
| pwa-app | 3013 | |
| react-app | 3014 | |
| actioncable-app | 3017 | 重複 |
| debug-app | 3017 | 重複 |
| stimulus-components-app | 3020 | |
| snabberb-app | 3030 | |
| component-base-app | 3031 | |
| rails-app | 3036 | vite_ruby の dev サーバー（`config/vite.json`）。Rails は 3000 |

新しい example は既存と重ならないポートを選ぶこと。

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

*最終更新: 2026-10-05 (v0.3.16 リリース、PR #62〜#67 後)*

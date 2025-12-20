# インストール

このガイドでは、さまざまなシナリオでのopal-viteのインストール方法を説明します。

## 必要条件

| 必要条件 | バージョン |
|---------|-----------|
| Node.js | 18以上 |
| Ruby | 3.0以上 |
| pnpm / npm | 最新版 |

## パッケージのインストール

### 1. Viteプラグイン（npm）

```bash
# pnpmを使用（推奨）
pnpm add -D vite-plugin-opal

# npmを使用
npm install -D vite-plugin-opal
```

### 2. Ruby Gem

```bash
# 直接インストール
gem install opal opal-vite

# またはGemfileに追加
bundle add opal opal-vite
```

### Gemfile

```ruby
source 'https://rubygems.org'

gem 'opal', '~> 1.8'
gem 'opal-vite', '~> 0.2'
```

その後：

```bash
bundle install
```

## 設定

### vite.config.ts

```typescript
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      // Rubyソースディレクトリ
      loadPaths: ['./app/opal'],

      // デバッグ用ソースマップを有効化
      sourceMap: true,

      // デバッグ出力を有効化（オプション）
      debug: false
    })
  ]
})
```

### プラグインオプション

| オプション | 型 | デフォルト | 説明 |
|-----------|-----|----------|------|
| `loadPaths` | `string[]` | `['./app/opal']` | Rubyソースファイルを含むディレクトリ |
| `sourceMap` | `boolean` | `true` | デバッグ用ソースマップを生成 |
| `debug` | `boolean` | `false` | デバッグ出力を有効化 |
| `compilerOptions` | `object` | `{}` | 追加のOpalコンパイラオプション |

## プロジェクトセットアップ

### 1. ディレクトリ構造の作成

```bash
mkdir -p app/opal/controllers
```

### 2. エントリーポイントの作成

```ruby
# app/opal/application.rb
require 'opal'

puts "opal-vite is working!"
```

### 3. JavaScriptローダーの作成

```javascript
// src/main.js
import './app/opal/application.rb'
```

### 4. index.htmlの更新

```html
<!DOCTYPE html>
<html>
<head>
  <title>My Opal App</title>
</head>
<body>
  <script type="module" src="/src/main.js"></script>
</body>
</html>
```

### 5. 開発サーバーの起動

```bash
pnpm dev
```

## Bundlerとの使用

Gemfileがある場合、プラグインは自動的に`bundle exec`を使用してコンパイラを実行します：

```bash
# 自動検出
bundle exec ruby -r opal/vite/compiler ...
```

## インストールの確認

開発サーバーを起動後、ブラウザコンソールを開くと以下が表示されます：

```
opal-vite is working!
```

## 次のステップ

- [クイックスタート](/ja/guide/getting-started) - 最初のアプリを作成
- [APIリファレンス](/ja/api/v1/) - OpalVite Helpersを探索

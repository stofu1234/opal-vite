---
layout: home

hero:
  name: opal-vite
  text: ブラウザでRubyを動かす
  tagline: Viteの高速な開発体験でRubyコードをブラウザ上で実行
  image:
    src: /hero.png
    alt: opal-vite ロゴ
  actions:
    - theme: brand
      text: はじめる
      link: /ja/guide/getting-started
    - theme: alt
      text: GitHub
      link: https://github.com/stofu1234/opal-vite

features:
  - icon: ⚡️
    title: 高速開発
    details: Viteの瞬時のサーバー起動とホットモジュールリプレースメントでシームレスな開発体験を実現。
  - icon: 💎
    title: ブラウザでRuby
    details: Opalを通じてRubyコードをJavaScriptにコンパイル。使い慣れたRubyの構文とパターンを使用できます。
  - icon: 🔥
    title: ホットリロード
    details: ページリロードなしで変更を即座に反映。Rubyコードを編集するとリアルタイムで更新されます。
  - icon: 🗺️
    title: ソースマップ対応
    details: ブラウザのDevToolsでRubyコードを直接デバッグ。完全なソースマップをサポート。
  - icon: 📦
    title: ランタイム自動読み込み
    details: Opalランタイムは自動的に読み込まれます。手動設定は不要です。
  - icon: 🎯
    title: Stimulus連携
    details: OpalVite HelpersでStimulusコントローラーをRubyで記述。DOM操作などを簡単に。
---

## クイックインストール

### npm / pnpm

```bash
# Viteプラグインをインストール
pnpm add -D vite-plugin-opal

# Ruby gemをインストール
gem install opal-vite
```

### Gemfile

```ruby
gem 'opal'
gem 'opal-vite'
```

## 基本設定

### vite.config.ts

```typescript
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      loadPaths: ['./app/opal'],
      sourceMap: true
    })
  ]
})
```

### 最初のRubyファイル

```ruby
# app/opal/application.rb
puts "Hello from Ruby!"

class Greeter
  def initialize(name)
    @name = name
  end

  def greet
    puts "Hello, #{@name}!"
  end
end

Greeter.new("World").greet
```

## Playground

ライブデモでopal-viteを体験：

- [Practical App](https://stofu1234.github.io/opal-vite/playground/practical-app/) - フル機能Todoアプリ
- [Chart App](https://stofu1234.github.io/opal-vite/playground/chart-app/) - チャート可視化
- [Stimulus App](https://stofu1234.github.io/opal-vite/playground/stimulus-app/) - Stimulusコントローラー基本
- [API Example](https://stofu1234.github.io/opal-vite/playground/api-example/) - API連携パターン
- [Form Validation](https://stofu1234.github.io/opal-vite/playground/form-validation-app/) - リアルタイムバリデーション
- [i18n App](https://stofu1234.github.io/opal-vite/playground/i18n-app/) - 多言語対応
- [PWA App](https://stofu1234.github.io/opal-vite/playground/pwa-app/) - オフライン対応
- [Vue App](https://stofu1234.github.io/opal-vite/playground/vue-app/) - Vue.js統合
- [React App](https://stofu1234.github.io/opal-vite/playground/react-app/) - React統合

すべてのデモは[Playground](/ja/playground)ページで確認できます。

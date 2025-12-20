# クイックスタート

opal-viteは[Opal](https://opalrb.com/)と[Vite](https://vitejs.dev/)を統合し、ブラウザで動作するRubyコードを記述できるようにします。

## 前提条件

- Node.js 18以上
- Ruby 3.0以上
- pnpm（推奨）またはnpm

## クイックスタート

opal-viteを試す最も簡単な方法はpractical-appサンプルを使うことです：

```bash
# リポジトリをクローン
git clone https://github.com/stofu1234/opal-vite.git
cd opal-vite

# ルートの依存関係をインストール
pnpm install

# practical-appサンプルに移動
cd examples/practical-app

# 依存関係をインストール
bundle install
pnpm install

# 開発サーバーを起動
pnpm dev
```

`http://localhost:3002` を開くと、Rubyで構築されたフル機能のTodoアプリが表示されます！

## プロジェクト構造

```
my-opal-app/
├── app/
│   └── opal/
│       ├── application.rb      # メインエントリーポイント
│       └── controllers/        # Stimulusコントローラー
├── index.html
├── vite.config.ts
├── package.json
└── Gemfile
```

## 次のステップ

- [インストールガイド](/ja/guide/installation) - 詳細なインストール手順
- [APIリファレンス](/ja/api/v1/) - OpalVite Helpersについて
- [トラブルシューティング](/ja/guide/troubleshooting) - よくある問題と解決策

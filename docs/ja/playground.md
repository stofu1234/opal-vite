# Playground

::: warning 準備中
インタラクティブなPlaygroundは現在開発中です。
:::

## 提供予定の機能

opal-vite Playgroundでは以下が可能になります：

- ブラウザ上でRubyコードを記述
- コンパイルされたJavaScriptをリアルタイムで確認
- Stimulusコントローラーをインタラクティブにテスト
- コードスニペットの共有

## 現在お試しいただく方法

ローカル環境でリポジトリをクローンしてお試しください：

```bash
git clone https://github.com/stofu1234/opal-vite.git
cd opal-vite/examples/practical-app
pnpm install && bundle install
pnpm dev
```

## サンプルアプリケーション

opal-viteの動作を確認できるサンプルアプリケーション：

| サンプル | 説明 |
|---------|------|
| practical-app | CRUD、モーダル、トースト機能を持つフル機能Todoアプリ |
| stimulus-app | Stimulusコントローラー連携のサンプル |
| chart-app | Opalによるチャート可視化 |
| api-example | API連携パターン |

インタラクティブなPlaygroundの公開をお楽しみに！

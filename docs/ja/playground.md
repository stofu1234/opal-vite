# Playground

opal-viteのサンプルアプリケーションを実際に試すことができます。

## Live Demos

<div class="playground-grid">

### Practical App
フル機能のTodoアプリケーション。CRUD操作、モーダル、トースト通知、LocalStorage永続化など。

[**デモを開く**](https://stofu1234.github.io/opal-vite/playground/practical-app/)

---

### Chart App
Chart.jsを使用したチャート可視化のサンプル。

[**デモを開く**](https://stofu1234.github.io/opal-vite/playground/chart-app/)

---

### Stimulus App
Stimulusコントローラーの基本的な使い方を示すサンプル。

[**デモを開く**](https://stofu1234.github.io/opal-vite/playground/stimulus-app/)

---

### API Example
外部APIとの連携パターンを示すサンプル。

[**デモを開く**](https://stofu1234.github.io/opal-vite/playground/api-example/)

---

### Form Validation App
リアルタイムフォームバリデーションのサンプル。

[**デモを開く**](https://stofu1234.github.io/opal-vite/playground/form-validation-app/)

---

### i18n App
多言語対応（国際化）のサンプル。

[**デモを開く**](https://stofu1234.github.io/opal-vite/playground/i18n-app/)

---

### PWA App
Progressive Web Appのサンプル。オフライン対応。

[**デモを開く**](https://stofu1234.github.io/opal-vite/playground/pwa-app/)

---

### Turbo App
Hotwire Turboとの統合サンプル。

[**デモを開く**](https://stofu1234.github.io/opal-vite/playground/turbo-app/)

---

### Vue App
Vue.js 3との統合サンプル。Rubyでロジックを記述。

[**デモを開く**](https://stofu1234.github.io/opal-vite/playground/vue-app/)

---

### React App
Reactとの統合サンプル。Rubyでロジックを記述。

[**デモを開く**](https://stofu1234.github.io/opal-vite/playground/react-app/)

---

### Snabberb App
Snabberb SPAフレームワークのサンプル。仮想DOMを使用したカウンターとTodoアプリ。

[**デモを開く**](https://stofu1234.github.io/opal-vite/playground/snabberb-app/)

---

### ActionCable App (Railway)
ActionCableHelpersを使用したリアルタイムチャットのデモ。WebSocket通信、タイピングインジケーター、オンラインプレゼンス。

[**デモを開く**](https://opal-vite-actioncable-demo-production.up.railway.app/)

---

### Chat App (Railway)
WebSocketを使用したリアルタイムチャットアプリ。複数ユーザー対応。

[**デモを開く**](https://opal-vite-chat-demo-production.up.railway.app)

---

### Rails App (Railway)
Rails + Opal + Viteの統合サンプル。サーバーサイドRailsとクライアントサイドOpalの連携。

[**デモを開く**](https://opal-vite-rails-demo-production.up.railway.app)

</div>

## ソースコード

各サンプルのソースコードはGitHubリポジトリで確認できます：

- [practical-app](https://github.com/stofu1234/opal-vite/tree/master/examples/practical-app)
- [chart-app](https://github.com/stofu1234/opal-vite/tree/master/examples/chart-app)
- [stimulus-app](https://github.com/stofu1234/opal-vite/tree/master/examples/stimulus-app)
- [api-example](https://github.com/stofu1234/opal-vite/tree/master/examples/api-example)
- [form-validation-app](https://github.com/stofu1234/opal-vite/tree/master/examples/form-validation-app)
- [i18n-app](https://github.com/stofu1234/opal-vite/tree/master/examples/i18n-app)
- [pwa-app](https://github.com/stofu1234/opal-vite/tree/master/examples/pwa-app)
- [turbo-app](https://github.com/stofu1234/opal-vite/tree/master/examples/turbo-app)
- [vue-app](https://github.com/stofu1234/opal-vite/tree/master/examples/vue-app)
- [react-app](https://github.com/stofu1234/opal-vite/tree/master/examples/react-app)
- [snabberb-app](https://github.com/stofu1234/opal-vite/tree/master/examples/snabberb-app)
- [actioncable-app](https://github.com/stofu1234/opal-vite/tree/master/examples/actioncable-app)
- [chat-app](https://github.com/stofu1234/opal-vite/tree/master/examples/chat-app)
- [rails-app](https://github.com/stofu1234/opal-vite/tree/master/examples/rails-app)

## ローカルで実行

ローカル環境で実行する場合：

```bash
git clone https://github.com/stofu1234/opal-vite.git
cd opal-vite/examples/practical-app
pnpm install && bundle install
pnpm dev
```

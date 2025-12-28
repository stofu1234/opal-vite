# 本番ビルドの最適化

このガイドでは、Opal + Viteアプリケーションを本番環境にデプロイする際のベストプラクティスを説明します。

## デフォルトのMinify

Viteはデフォルトで[esbuild](https://esbuild.github.io/)を使用してminifyを行います：

- 高速なビルド
- 変数名の短縮
- 未使用コードの削除
- 空白の削除

ほとんどのアプリケーションではこれで十分です。

## Terserによる強化されたMinify

より高い圧縮率（5-6%小さい出力）を得るには、[Terser](https://terser.org/)を使用できます：

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [opal()],
  build: {
    minify: 'terser',
    terserOptions: {
      compress: {
        passes: 2
      },
      mangle: true,
      format: {
        comments: false
      }
    }
  }
})
```

### サイズ比較

| Minifier | 生サイズ | Gzipサイズ |
|----------|----------|------------|
| esbuild (デフォルト) | 374 KB | 104 KB |
| Terser | 359 KB | 98 KB |

::: tip
Terserを開発依存としてインストール：
```bash
pnpm add -D terser
```
:::

## 本番環境でのソースマップ

本番ビルドでは、バンドルサイズを削減しソースコードを隠すためにソースマップを無効にすることを検討してください：

```typescript
// vite.config.ts
export default defineConfig({
  plugins: [
    opal({
      sourceMap: false  // Opalソースマップを無効化
    })
  ],
  build: {
    sourcemap: false    // Viteソースマップを無効化
  }
})
```

## Opal出力の理解

### Minifyされるもの

- **変数名**: 単一文字に短縮（`e`, `k`, `H`など）
- **コメント**: 完全に削除
- **空白**: 削除

### 可読性が残るもの

Rubyのメタプログラミング機能（`method_missing`, `respond_to?`, `send`）のため、以下は文字列識別子として残ります：

- **Rubyクラス名**: `$Array`, `$String`, `$Hash`など
- **Rubyメソッド名**: `.$to_s`, `.$inspect`, `.$each`など

これは設計上の仕様であり、Ruby互換性を損なわずに変更することはできません。

### 他のSPAとの比較

| 機能 | React/Vue | Opal |
|------|-----------|------|
| 変数名 | Minify済み | Minify済み |
| 関数名 | Minify済み | 保持（文字列） |
| クラス名 | Minify済み | 保持（文字列） |

## 推奨本番設定

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      sourceMap: false,      // 本番ではソースマップなし
      debug: false           // デバッグ出力なし
    })
  ],
  build: {
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,  // console.logを削除
        passes: 2
      },
      mangle: true,
      format: {
        comments: false
      }
    },
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: {
          // Opalランタイムを別チャンクに分割してキャッシュ効率向上
          'opal-runtime': ['/@opal-runtime']
        }
      }
    }
  }
})
```

## セキュリティに関する考慮事項

::: warning
ブラウザ内のJavaScriptは常にユーザーがアクセス可能です。本当に機密性の高いロジックについては：

1. **サーバーサイドに移動**: ビジネスロジックはバックエンドAPIに保持
2. **認証を使用**: 機密性の高いエンドポイントを保護
3. **サーバーサイドで検証**: クライアントサイドの検証のみを信頼しない
:::

Minifyと難読化は抑止力であり、セキュリティ対策ではありません。コードを理解するために必要な労力を増やしますが、決意を持ったリバースエンジニアリングを防ぐことはできません。

## パフォーマンスのヒント

### 1. コード分割

アプリケーションを小さなチャンクに分割：

```typescript
// ルートや機能を遅延ロード
const AdminPanel = await import('./admin_panel.rb')
```

### 2. Tree Shaking

必要なものだけをインポート：

```ruby
# 良い - 特定のインポート
require 'opal_vite/concerns/storable'

# 避ける - すべてをインポート
require 'opal_vite'
```

### 3. 重要なアセットのプリロード

```html
<link rel="modulepreload" href="/assets/opal-runtime.js">
```

## 環境別の設定

Viteの環境モードを使用：

```typescript
// vite.config.ts
export default defineConfig(({ mode }) => ({
  plugins: [
    opal({
      sourceMap: mode === 'development',
      debug: mode === 'development'
    })
  ],
  build: {
    minify: mode === 'production' ? 'terser' : false,
    sourcemap: mode === 'development'
  }
}))
```

## 関連

- [ソースマップ](./source-maps.md)
- [トラブルシューティング](./troubleshooting.md)

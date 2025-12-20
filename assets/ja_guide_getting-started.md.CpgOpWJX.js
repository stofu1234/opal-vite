import{_ as s,c as i,o as n,ag as l}from"./chunks/framework.dvv-DFtf.js";const k=JSON.parse('{"title":"クイックスタート","description":"","frontmatter":{},"headers":[],"relativePath":"ja/guide/getting-started.md","filePath":"ja/guide/getting-started.md"}'),p={name:"ja/guide/getting-started.md"};function e(t,a,h,r,d,o){return n(),i("div",null,[...a[0]||(a[0]=[l(`<h1 id="クイックスタート" tabindex="-1">クイックスタート <a class="header-anchor" href="#クイックスタート" aria-label="Permalink to &quot;クイックスタート&quot;">​</a></h1><p>opal-viteは<a href="https://opalrb.com/" target="_blank" rel="noreferrer">Opal</a>と<a href="https://vitejs.dev/" target="_blank" rel="noreferrer">Vite</a>を統合し、ブラウザで動作するRubyコードを記述できるようにします。</p><h2 id="前提条件" tabindex="-1">前提条件 <a class="header-anchor" href="#前提条件" aria-label="Permalink to &quot;前提条件&quot;">​</a></h2><ul><li>Node.js 18以上</li><li>Ruby 3.0以上</li><li>pnpm（推奨）またはnpm</li></ul><h2 id="クイックスタート-1" tabindex="-1">クイックスタート <a class="header-anchor" href="#クイックスタート-1" aria-label="Permalink to &quot;クイックスタート&quot;">​</a></h2><p>opal-viteを試す最も簡単な方法はpractical-appサンプルを使うことです：</p><div class="language-bash vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">bash</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># リポジトリをクローン</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">git</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> clone</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> https://github.com/stofu1234/opal-vite.git</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">cd</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> opal-vite</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># ルートの依存関係をインストール</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">pnpm</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> install</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># practical-appサンプルに移動</span></span>
<span class="line"><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">cd</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> examples/practical-app</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 依存関係をインストール</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">bundle</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> install</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">pnpm</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> install</span></span>
<span class="line"></span>
<span class="line"><span style="--shiki-light:#6A737D;--shiki-dark:#6A737D;"># 開発サーバーを起動</span></span>
<span class="line"><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">pnpm</span><span style="--shiki-light:#032F62;--shiki-dark:#9ECBFF;"> dev</span></span></code></pre></div><p><code>http://localhost:3002</code> を開くと、Rubyで構築されたフル機能のTodoアプリが表示されます！</p><h2 id="プロジェクト構造" tabindex="-1">プロジェクト構造 <a class="header-anchor" href="#プロジェクト構造" aria-label="Permalink to &quot;プロジェクト構造&quot;">​</a></h2><div class="language- vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang"></span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span>my-opal-app/</span></span>
<span class="line"><span>├── app/</span></span>
<span class="line"><span>│   └── opal/</span></span>
<span class="line"><span>│       ├── application.rb      # メインエントリーポイント</span></span>
<span class="line"><span>│       └── controllers/        # Stimulusコントローラー</span></span>
<span class="line"><span>├── index.html</span></span>
<span class="line"><span>├── vite.config.ts</span></span>
<span class="line"><span>├── package.json</span></span>
<span class="line"><span>└── Gemfile</span></span></code></pre></div><h2 id="次のステップ" tabindex="-1">次のステップ <a class="header-anchor" href="#次のステップ" aria-label="Permalink to &quot;次のステップ&quot;">​</a></h2><ul><li><a href="/ja/guide/installation.html">インストールガイド</a> - 詳細なインストール手順</li><li><a href="/ja/api/v1/">APIリファレンス</a> - OpalVite Helpersについて</li><li><a href="/ja/guide/troubleshooting.html">トラブルシューティング</a> - よくある問題と解決策</li></ul>`,12)])])}const g=s(p,[["render",e]]);export{k as __pageData,g as default};

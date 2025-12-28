import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'opal-vite',
  description: 'Ruby in the Browser with Vite',

  // Base URL for GitHub Pages (stofu1234.github.io/opal-vite/)
  base: '/opal-vite/',

  // Ignore dead links during build (some documents are WIP)
  ignoreDeadLinks: true,

  // Favicon and meta
  head: [
    ['link', { rel: 'icon', type: 'image/png', sizes: '16x16', href: '/opal-vite/opal_vite_speed_16.png' }],
    ['link', { rel: 'icon', type: 'image/png', sizes: '48x48', href: '/opal-vite/opal_vite_speed_48.png' }],
    ['link', { rel: 'apple-touch-icon', sizes: '128x128', href: '/opal-vite/opal_vite_speed_128.png' }]
  ],

  // i18n configuration
  locales: {
    root: {
      label: 'English',
      lang: 'en',
      themeConfig: {
        nav: [
          { text: 'Home', link: '/' },
          { text: 'Guide', link: '/guide/getting-started' },
          { text: 'API', link: '/api/v1/' },
          { text: 'Playground', link: '/playground' }
        ],
        sidebar: {
          '/guide/': [
            {
              text: 'Introduction',
              items: [
                { text: 'Getting Started', link: '/guide/getting-started' },
                { text: 'Installation', link: '/guide/installation' },
                { text: 'Examples', link: '/guide/examples' }
              ]
            },
            {
              text: 'Advanced',
              items: [
                { text: 'Production Build', link: '/guide/production-build' },
                { text: 'Migration', link: '/guide/migration' },
                { text: 'Source Maps', link: '/guide/source-maps' },
                { text: 'Testing', link: '/guide/testing' },
                { text: 'Troubleshooting', link: '/guide/troubleshooting' }
              ]
            }
          ],
          '/api/v1/': [
            {
              text: 'API Reference',
              items: [
                { text: 'Overview', link: '/api/v1/' },
                { text: 'Stimulus API (v0.3.0)', link: '/api/v1/en/stimulus_api' },
                { text: 'StimulusHelpers', link: '/api/v1/en/stimulus_helpers' },
                { text: 'DomHelpers', link: '/api/v1/en/dom_helpers' },
                { text: 'Storable', link: '/api/v1/en/storable' },
                { text: 'Toastable', link: '/api/v1/en/toastable' },
                { text: 'JsProxyEx', link: '/api/v1/en/js_proxy_ex' },
                { text: 'VueHelpers', link: '/api/v1/en/vue_helpers' },
                { text: 'ReactHelpers', link: '/api/v1/en/react_helpers' }
              ]
            }
          ]
        }
      }
    },
    ja: {
      label: '日本語',
      lang: 'ja',
      link: '/ja/',
      themeConfig: {
        nav: [
          { text: 'ホーム', link: '/ja/' },
          { text: 'ガイド', link: '/ja/guide/getting-started' },
          { text: 'API', link: '/ja/api/v1/' },
          { text: 'Playground', link: '/ja/playground' }
        ],
        sidebar: {
          '/ja/guide/': [
            {
              text: 'はじめに',
              items: [
                { text: 'クイックスタート', link: '/ja/guide/getting-started' },
                { text: 'インストール', link: '/ja/guide/installation' },
                { text: 'サンプル', link: '/ja/guide/examples' }
              ]
            },
            {
              text: '詳細',
              items: [
                { text: '本番ビルド', link: '/ja/guide/production-build' },
                { text: 'マイグレーション', link: '/ja/guide/migration' },
                { text: 'ソースマップ', link: '/ja/guide/source-maps' },
                { text: 'テスト', link: '/ja/guide/testing' },
                { text: 'トラブルシューティング', link: '/ja/guide/troubleshooting' }
              ]
            }
          ],
          '/ja/api/v1/': [
            {
              text: 'APIリファレンス',
              items: [
                { text: '概要', link: '/ja/api/v1/' },
                { text: 'StimulusHelpers', link: '/api/v1/ja/stimulus_helpers' },
                { text: 'DomHelpers', link: '/api/v1/ja/dom_helpers' },
                { text: 'Storable', link: '/api/v1/ja/storable' },
                { text: 'Toastable', link: '/api/v1/ja/toastable' },
                { text: 'JsProxyEx', link: '/api/v1/ja/js_proxy_ex' },
                { text: 'VueHelpers', link: '/api/v1/ja/vue_helpers' },
                { text: 'ReactHelpers', link: '/api/v1/ja/react_helpers' }
              ]
            }
          ]
        }
      }
    }
  },

  themeConfig: {
    logo: '/opal_vite_speed_48.png',

    socialLinks: [
      { icon: 'github', link: 'https://github.com/stofu1234/opal-vite' }
    ],

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'Copyright © 2024-present stofu1234'
    },

    search: {
      provider: 'local'
    }
  }
})

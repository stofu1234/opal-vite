import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    opal({
      gemPath: '../../gems/opal-vite',
      loadPaths: ['./app/frontend/opal'],
      sourceMap: true,
      debug: process.env.NODE_ENV === 'development'
    })
  ]
})

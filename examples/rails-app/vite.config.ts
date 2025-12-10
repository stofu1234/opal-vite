import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      gemPath: '../../gems/opal-vite',
      loadPaths: ['./app/opal'],
      sourceMap: true,
      debug: process.env.NODE_ENV === 'development'
    })
  ],
  build: {
    manifest: true,
    rollupOptions: {
      input: {
        'application': './app/opal/application_loader.js'
      }
    }
  }
})

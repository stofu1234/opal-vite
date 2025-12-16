import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      loadPaths: ['./app/opal'],
      sourceMap: true,
      includeConcerns: true
    })
  ],
  server: {
    port: 3006,
    proxy: {
      '/ws': {
        target: 'ws://localhost:3007',
        ws: true
      }
    }
  }
})

import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      loadPaths: ['./app/opal/controllers'],
      sourceMap: true,
      includeConcerns: true,
      debug: process.env.DEBUG === '1'
    })
  ],
  server: {
    port: 3001
  },
  build: {
    sourcemap: true
  }
})

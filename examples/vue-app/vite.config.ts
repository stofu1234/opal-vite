import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      loadPaths: ['./src'],
      sourceMap: true,
      includeConcerns: true,
      debug: process.env.DEBUG === '1'
    })
  ],
  server: {
    port: 3010
  }
})

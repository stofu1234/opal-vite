import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      loadPaths: ['./app/opal/controllers'],
      // Source maps disabled: Vite's source map chain has compatibility issues
      // with Opal's index source map format (multiple sections)
      sourceMap: false,
      includeConcerns: true,
      debug: process.env.DEBUG === '1'
    })
  ],
  server: {
    port: 3001
  }
})

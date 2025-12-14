import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      loadPaths: ['./app/opal/controllers'],
      sourceMap: true
    })
  ],
  server: {
    port: 3002
  }
})

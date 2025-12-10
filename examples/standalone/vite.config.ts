import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'
import * as path from 'path'

export default defineConfig({
  plugins: [
    opal({
      // Point to the local gem for development
      gemPath: path.resolve(__dirname, '../../gems/opal-vite'),
      loadPaths: ['./src'],
      sourceMap: true,
      debug: true
    })
  ],
  server: {
    port: 3000
  }
})

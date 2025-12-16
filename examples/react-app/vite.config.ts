import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import opal from 'vite-plugin-opal'
import * as path from 'path'

export default defineConfig({
  plugins: [
    react(),
    opal({
      gemPath: path.resolve(__dirname, '../../gems/opal-vite'),
      loadPaths: ['./src'],
      sourceMap: true,
      debug: true,
      includeConcerns: true
    })
  ],
  server: {
    port: 3001
  }
})

import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  base: process.env.VITE_BASE || '/',
  plugins: [
    opal({
      loadPaths: ['./app/opal', './app/opal/controllers', './app/opal/services'],
      sourceMap: true,
      includeConcerns: true
    })
  ],
  server: {
    port: 3017
  }
})

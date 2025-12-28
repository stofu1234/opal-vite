import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      debug: true
    })
  ],
  server: {
    port: 3008
  },
  base: process.env.VITE_BASE || '/'
})

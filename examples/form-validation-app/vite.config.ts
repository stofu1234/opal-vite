import { defineConfig } from 'vite';
import opal from 'vite-plugin-opal';

export default defineConfig({
  base: process.env.VITE_BASE || '/',
  plugins: [opal({
      stubs: [
        'base64'
      ]
  })],
  server: {
    port: 3011
  }
});

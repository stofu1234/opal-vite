import { defineConfig } from 'vite';
import opal from 'vite-plugin-opal';

export default defineConfig({
  base: process.env.VITE_BASE || '/',
  plugins: [opal()],
  server: {
    port: 3012
  }
});

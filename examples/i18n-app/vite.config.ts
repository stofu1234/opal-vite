import { defineConfig } from 'vite';
import opal from 'vite-plugin-opal';

export default defineConfig({
  plugins: [opal()],
  server: {
    port: 3012
  }
});

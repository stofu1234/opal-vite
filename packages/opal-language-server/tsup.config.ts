import { defineConfig } from 'tsup';

export default defineConfig({
  entry: {
    server: 'src/server.ts',
    patterns: 'src/patterns.ts',
    snippets: 'src/snippets.ts'
  },
  format: ['cjs'],
  dts: false,
  clean: true,
  sourcemap: true,
  target: 'node18',
  shims: true
});

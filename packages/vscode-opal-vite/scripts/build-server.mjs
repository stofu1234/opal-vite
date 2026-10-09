// Bundle opal-language-server into the extension (server/dist/server.js),
// where findServerModule() looks for it first. The published .vsix ships no
// node_modules, so the server and its dependencies are bundled into one file,
// and its data files are copied next to it (the server reads ../data/*.json).
import { build } from 'esbuild';
import { cpSync, rmSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const serverPackage = join(root, '..', 'opal-language-server');
const outDir = join(root, 'server');

rmSync(outDir, { recursive: true, force: true });

await build({
  entryPoints: [join(serverPackage, 'src', 'server.ts')],
  outfile: join(outDir, 'dist', 'server.js'),
  bundle: true,
  minify: true,
  platform: 'node',
  format: 'cjs',
  target: 'node18',
  // The server source is ESM and locates its data with import.meta.url,
  // which is empty in a CommonJS bundle.
  banner: { js: "const __importMetaUrl = require('url').pathToFileURL(__filename).href;" },
  define: { 'import.meta.url': '__importMetaUrl' },
});

cpSync(join(serverPackage, 'data'), join(outDir, 'data'), { recursive: true });

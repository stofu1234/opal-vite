import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { createServer, type ViteDevServer } from 'vite'
import opalPlugin from '../src/index'
import * as path from 'path'
import * as fs from 'fs'
import * as os from 'os'

// Path to local gem for testing (monorepo structure)
const LOCAL_GEM_PATH = path.resolve(__dirname, '../../../gems/opal-vite')

// The plugin loads .rb files itself, so Vite's own server.fs.allow check
// (done only for files no plugin loads) does not apply to them.
describe('dev server file access', () => {
  let base: string
  let root: string
  let outsidePath: string
  let server: ViteDevServer

  beforeAll(async () => {
    base = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), 'opal-fs-')))
    root = path.join(base, 'app')
    fs.mkdirSync(root)
    fs.writeFileSync(path.join(root, 'main.rb'), "puts 'inside-root'\n")
    outsidePath = path.join(base, 'secret.rb')
    fs.writeFileSync(outsidePath, "SECRET = 'outside-root'\n")

    server = await createServer({
      root,
      configFile: false,
      logLevel: 'silent',
      server: { middlewareMode: true, fs: { allow: [root] } },
      optimizeDeps: { noDiscovery: true, include: [] },
      plugins: [opalPlugin({ gemPath: LOCAL_GEM_PATH, diskCache: false })]
    })
  }, 30000)

  afterAll(async () => {
    await server?.close()
    if (base && fs.existsSync(base)) {
      fs.rmSync(base, { recursive: true })
    }
  })

  it('compiles .rb files inside the allow list', async () => {
    const result = await server.transformRequest('/main.rb')
    expect(result?.code).toContain('inside-root')
  }, 60000)

  it('refuses .rb files outside the allow list', async () => {
    await expect(server.transformRequest(`/@fs${outsidePath}`)).rejects.toThrow(/server\.fs\.allow/)
  }, 60000)
})

import { describe, it, expect, beforeAll, afterAll, vi } from 'vitest'
import { createServer, normalizePath, type ViteDevServer } from 'vite'
import opalPlugin from '../src/index'
import * as path from 'path'
import * as fs from 'fs'
import * as os from 'os'

// Path to local gem for testing (monorepo structure)
const LOCAL_GEM_PATH = path.resolve(__dirname, '../../../gems/opal-vite')

// Runs a real Vite dev server: Opal inlines `require`d files into the entry,
// so editing a required file must invalidate the entry and reload the page.
describe('HMR for required files', () => {
  let root: string
  let server: ViteDevServer
  let entryPath: string
  let depPath: string

  beforeAll(async () => {
    root = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), 'opal-hmr-')))
    entryPath = path.join(root, 'main.rb')
    depPath = path.join(root, 'lib', 'greeting.rb')
    fs.mkdirSync(path.dirname(depPath))
    fs.writeFileSync(entryPath, "require 'lib/greeting'\nputs greeting\n")
    fs.writeFileSync(depPath, "def greeting\n  'hello-v1'\nend\n")

    server = await createServer({
      root,
      configFile: false,
      logLevel: 'silent',
      server: { middlewareMode: true },
      optimizeDeps: { noDiscovery: true, include: [] },
      plugins: [opalPlugin({ gemPath: LOCAL_GEM_PATH, diskCache: false })]
    })
  }, 30000)

  afterAll(async () => {
    await server?.close()
    if (root && fs.existsSync(root)) {
      fs.rmSync(root, { recursive: true })
    }
  })

  it('reloads the entry when a required file changes', async () => {
    const first = await server.transformRequest('/main.rb')
    expect(first?.code).toContain('hello-v1')

    // The required file is registered in the module graph as a dependency
    // of the entry.
    const depModules = server.moduleGraph.getModulesByFile(normalizePath(depPath))
    expect(depModules?.size ?? 0).toBeGreaterThan(0)

    const sent: Array<{ type: string }> = []
    const send = vi.spyOn(server.hot, 'send').mockImplementation(((payload: { type: string }) => {
      sent.push(payload)
    }) as typeof server.hot.send)

    fs.writeFileSync(depPath, "def greeting\n  'hello-v2'\nend\n")
    // Make sure the mtime moves even on filesystems with coarse timestamps.
    const future = new Date(Date.now() + 5000)
    fs.utimesSync(depPath, future, future)
    server.watcher.emit('change', depPath)

    await vi.waitFor(() => {
      expect(sent.some((p) => p.type === 'full-reload' || p.type === 'update')).toBe(true)
    }, { timeout: 10000 })
    send.mockRestore()

    const second = await server.transformRequest('/main.rb')
    expect(second?.code).toContain('hello-v2')
    expect(second?.code).not.toContain('hello-v1')
  }, 60000)
})

import { describe, it, expect } from 'vitest'
import type { ViteDevServer } from 'vite'
import { isFileServingAllowedByServer } from '../src/fs-access'

const deny = (file: string) => /\.env$|\.pem$/.test(file)

function fakeServer(shape: 'vite5' | 'vite6' | 'unknown', fs: object = {}): ViteDevServer {
  const serverFs = { strict: true, allow: ['/proj'], deny: [], ...fs }
  const config: Record<string, unknown> = { server: { fs: serverFs } }
  const server: Record<string, unknown> = { config }
  if (shape === 'vite6') {
    config.fsDenyGlob = deny
    config.safeModulePaths = new Set(['/outside/safe.rb'])
  } else if (shape === 'vite5') {
    server._fsDenyGlob = deny
    server._safeModulePaths = new Set(['/outside/safe.rb'])
  }
  return server as unknown as ViteDevServer
}

describe('isFileServingAllowedByServer', () => {
  for (const shape of ['vite5', 'vite6'] as const) {
    describe(`server shaped like Vite ${shape === 'vite5' ? '5' : '6+'}`, () => {
      it('allows files under fs.allow', () => {
        expect(isFileServingAllowedByServer('/proj/app/a.rb', fakeServer(shape))).toBe(true)
        expect(isFileServingAllowedByServer('/proj', fakeServer(shape))).toBe(true)
      })

      it('rejects files outside fs.allow, including sibling prefixes', () => {
        expect(isFileServingAllowedByServer('/etc/a.rb', fakeServer(shape))).toBe(false)
        expect(isFileServingAllowedByServer('/proj-other/a.rb', fakeServer(shape))).toBe(false)
      })

      it('rejects files matching fs.deny', () => {
        expect(isFileServingAllowedByServer('/proj/secret.pem', fakeServer(shape))).toBe(false)
      })

      it('allows safe module paths', () => {
        expect(isFileServingAllowedByServer('/outside/safe.rb', fakeServer(shape))).toBe(true)
      })

      it('allows everything when fs.strict is false', () => {
        expect(isFileServingAllowedByServer('/etc/a.rb', fakeServer(shape, { strict: false }))).toBe(true)
      })
    })
  }

  it('fails closed when the deny matcher cannot be found', () => {
    expect(isFileServingAllowedByServer('/proj/a.rb', fakeServer('unknown'))).toBe(false)
  })

  it('rejects ids containing a colon (alternate data streams, URLs)', () => {
    expect(isFileServingAllowedByServer('/proj/a.rb:stream', fakeServer('vite6'))).toBe(false)
  })
})

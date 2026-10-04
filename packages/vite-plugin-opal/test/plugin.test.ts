import { describe, it, expect } from 'vitest'
import opalPlugin from '../src/index'
import type { OpalPluginOptions } from '../src/types'
import type { Plugin } from 'vite'

// transformIndexHtml is an object hook ({ order, handler }); call its handler.
function transformHtml(plugin: Plugin, html: string): string {
  const hook = plugin.transformIndexHtml as any
  const handler = typeof hook === 'function' ? hook : hook.handler
  return handler(html, {} as any)
}

describe('opalPlugin', () => {
  describe('plugin initialization', () => {
    it('creates plugin with default options', () => {
      const plugin = opalPlugin()

      expect(plugin).toBeDefined()
      expect(plugin.name).toBe('vite-plugin-opal')
      expect(plugin.enforce).toBe('pre')
    })

    it('creates plugin with custom options', () => {
      const options: OpalPluginOptions = {
        loadPaths: ['./custom/path'],
        sourceMap: false,
        debug: true
      }

      const plugin = opalPlugin(options)

      expect(plugin).toBeDefined()
      expect(plugin.name).toBe('vite-plugin-opal')
    })

    it('accepts all valid options', () => {
      const options: OpalPluginOptions = {
        gemPath: '/custom/gem',
        sourceMap: true,
        loadPaths: ['./app', './lib'],
        arityCheck: true,
        freezing: false,
        debug: false,
        useBundler: true
      }

      const plugin = opalPlugin(options)

      expect(plugin).toBeDefined()
    })

    it('works with empty options', () => {
      const plugin = opalPlugin({})

      expect(plugin).toBeDefined()
      expect(plugin.name).toBe('vite-plugin-opal')
    })
  })

  describe('plugin hooks', () => {
    it('has required hooks', () => {
      const plugin = opalPlugin()

      expect(plugin.resolveId).toBeDefined()
      expect(plugin.load).toBeDefined()
      expect(plugin.transformIndexHtml).toBeDefined()
      expect(plugin.configureServer).toBeDefined()
    })

    it('resolveId handles virtual runtime module', async () => {
      const plugin = opalPlugin()

      if (typeof plugin.resolveId === 'function') {
        const result = await plugin.resolveId.call(
          { meta: { watchMode: true } } as any,
          '/@opal-runtime',
          undefined,
          {} as any
        )

        expect(result).toBe('\0/@opal-runtime')
      }
    })

    it('resolveId processes .rb files', async () => {
      const plugin = opalPlugin()

      if (typeof plugin.resolveId === 'function') {
        const result = await plugin.resolveId.call(
          { meta: { watchMode: true } } as any,
          '/path/to/file.rb',
          undefined,
          {} as any
        )

        // Result should be defined (null or string), not undefined
        expect(result !== undefined).toBe(true)
      }
    })

    it('resolveId returns null for non-Ruby files', async () => {
      const plugin = opalPlugin()

      if (typeof plugin.resolveId === 'function') {
        const result = await plugin.resolveId.call(
          { meta: { watchMode: true } } as any,
          '/path/to/file.js',
          undefined,
          {} as any
        )

        expect(result).toBeNull()
      }
    })

    it('transformIndexHtml injects runtime script', () => {
      const plugin = opalPlugin()

      {
        const html = `
<!DOCTYPE html>
<html>
<head>
  <title>Test</title>
</head>
<body>
  <h1>Test</h1>
</body>
</html>
`
        const result = transformHtml(plugin, html)

        expect(result).toContain('/@opal-runtime')
        expect(result).toContain('<script type="module"')
      }
    })

    it('transformIndexHtml runs before Vite processes inline scripts', () => {
      // The runtime is injected as an inline module so Vite rewrites its
      // import to the same URL compiled .rb modules use (one evaluation).
      const plugin = opalPlugin()
      const hook = plugin.transformIndexHtml as any

      expect(hook.order).toBe('pre')
      expect(transformHtml(plugin, '<head></head>')).toContain('<script type="module">import "/@opal-runtime"</script>')
    })

    it('transformIndexHtml handles HTML without head tag', () => {
      const plugin = opalPlugin()

      {
        const html = '<div>Hello</div>'
        const result = transformHtml(plugin, html)

        expect(result).toContain('/@opal-runtime')
      }
    })
  })

  describe('options validation', () => {
    it('accepts boolean sourceMap option', () => {
      expect(() => opalPlugin({ sourceMap: true })).not.toThrow()
      expect(() => opalPlugin({ sourceMap: false })).not.toThrow()
    })

    it('accepts string array loadPaths option', () => {
      expect(() => opalPlugin({ loadPaths: [] })).not.toThrow()
      expect(() => opalPlugin({ loadPaths: ['./src'] })).not.toThrow()
      expect(() => opalPlugin({ loadPaths: ['./src', './lib'] })).not.toThrow()
    })

    it('accepts boolean debug option', () => {
      expect(() => opalPlugin({ debug: true })).not.toThrow()
      expect(() => opalPlugin({ debug: false })).not.toThrow()
    })

    it('accepts boolean useBundler option', () => {
      expect(() => opalPlugin({ useBundler: true })).not.toThrow()
      expect(() => opalPlugin({ useBundler: false })).not.toThrow()
    })
  })

  describe('type exports', () => {
    it('exports OpalPluginOptions type', () => {
      // This test verifies that the type is exported
      // TypeScript will catch any issues at compile time
      const options: OpalPluginOptions = {
        loadPaths: ['./test']
      }

      expect(options).toBeDefined()
    })
  })

  describe('CDN mode', () => {
    it('accepts cdn option with provider name', () => {
      expect(() => opalPlugin({ cdn: 'opalrb' })).not.toThrow()
      expect(() => opalPlugin({ cdn: 'jsdelivr' })).not.toThrow()
      expect(() => opalPlugin({ cdn: 'unpkg' })).not.toThrow()
    })

    it('accepts cdn option with custom URL', () => {
      expect(() => opalPlugin({ cdn: 'https://my-cdn.example.com/opal.js' })).not.toThrow()
    })

    it('accepts cdn option set to false', () => {
      expect(() => opalPlugin({ cdn: false })).not.toThrow()
    })

    it('accepts opalVersion option', () => {
      expect(() => opalPlugin({ cdn: 'jsdelivr', opalVersion: '1.7.0' })).not.toThrow()
    })

    it('transformIndexHtml injects CDN script tag when cdn is enabled', () => {
      const plugin = opalPlugin({ cdn: 'opalrb' })

      {
        const html = `
<!DOCTYPE html>
<html>
<head>
  <title>Test</title>
</head>
<body>
  <h1>Test</h1>
</body>
</html>
`
        const result = transformHtml(plugin, html)

        expect(result).toContain('https://cdn.opalrb.com/opal/')
        expect(result).toContain('<script src="')
        // Should NOT contain the virtual runtime module
        expect(result).not.toContain('type="module"')
      }
    })

    it('transformIndexHtml uses correct CDN URL for jsdelivr', () => {
      const plugin = opalPlugin({ cdn: 'jsdelivr' })

      {
        const html = '<head></head>'
        const result = transformHtml(plugin, html)

        expect(result).toContain('https://cdn.jsdelivr.net/gh/opal/opal-cdn@')
      }
    })

    it('transformIndexHtml uses correct CDN URL for unpkg (opalrb fallback)', () => {
      const plugin = opalPlugin({ cdn: 'unpkg' })

      {
        const html = '<head></head>'
        const result = transformHtml(plugin, html)

        expect(result).toContain('https://cdn.opalrb.com/opal/')
      }
    })

    it('transformIndexHtml uses custom CDN URL', () => {
      const customUrl = 'https://my-cdn.example.com/opal/1.8.2/opal.min.js'
      const plugin = opalPlugin({ cdn: customUrl })

      {
        const html = '<head></head>'
        const result = transformHtml(plugin, html)

        expect(result).toContain(customUrl)
      }
    })

    it('transformIndexHtml respects opalVersion in CDN URL', () => {
      const plugin = opalPlugin({ cdn: 'jsdelivr', opalVersion: '1.7.0' })

      {
        const html = '<head></head>'
        const result = transformHtml(plugin, html)

        expect(result).toContain('@1.7.0')
      }
    })

    it('transformIndexHtml injects virtual runtime when cdn is disabled', () => {
      const plugin = opalPlugin({ cdn: false })

      {
        const html = '<head></head>'
        const result = transformHtml(plugin, html)

        expect(result).toContain('/@opal-runtime')
        expect(result).toContain('type="module"')
      }
    })

    it('transformIndexHtml injects virtual runtime when cdn is not specified', () => {
      const plugin = opalPlugin()

      {
        const html = '<head></head>'
        const result = transformHtml(plugin, html)

        expect(result).toContain('/@opal-runtime')
        expect(result).toContain('type="module"')
      }
    })
  })
})

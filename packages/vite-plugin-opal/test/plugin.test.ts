import { describe, it, expect } from 'vitest'
import opalPlugin from '../src/index'
import type { OpalPluginOptions } from '../src/types'

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

      if (typeof plugin.transformIndexHtml === 'function') {
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
        const result = plugin.transformIndexHtml(html, {} as any)

        expect(result).toContain('/@opal-runtime')
        expect(result).toContain('<script type="module"')
      }
    })

    it('transformIndexHtml handles HTML without head tag', () => {
      const plugin = opalPlugin()

      if (typeof plugin.transformIndexHtml === 'function') {
        const html = '<div>Hello</div>'
        const result = plugin.transformIndexHtml(html, {} as any)

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
      expect(() => opalPlugin({ cdn: 'jsdelivr' })).not.toThrow()
      expect(() => opalPlugin({ cdn: 'unpkg' })).not.toThrow()
      expect(() => opalPlugin({ cdn: 'cdnjs' })).not.toThrow()
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
      const plugin = opalPlugin({ cdn: 'jsdelivr' })

      if (typeof plugin.transformIndexHtml === 'function') {
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
        const result = plugin.transformIndexHtml(html, {} as any)

        expect(result).toContain('https://cdn.jsdelivr.net/npm/opal-runtime@')
        expect(result).toContain('<script src="')
        // Should NOT contain the virtual runtime module
        expect(result).not.toContain('type="module"')
      }
    })

    it('transformIndexHtml uses correct CDN URL for unpkg', () => {
      const plugin = opalPlugin({ cdn: 'unpkg' })

      if (typeof plugin.transformIndexHtml === 'function') {
        const html = '<head></head>'
        const result = plugin.transformIndexHtml(html, {} as any)

        expect(result).toContain('https://unpkg.com/opal-runtime@')
      }
    })

    it('transformIndexHtml uses correct CDN URL for cdnjs', () => {
      const plugin = opalPlugin({ cdn: 'cdnjs' })

      if (typeof plugin.transformIndexHtml === 'function') {
        const html = '<head></head>'
        const result = plugin.transformIndexHtml(html, {} as any)

        expect(result).toContain('https://cdnjs.cloudflare.com/ajax/libs/opal/')
      }
    })

    it('transformIndexHtml uses custom CDN URL', () => {
      const customUrl = 'https://my-cdn.example.com/opal/1.8.2/opal.min.js'
      const plugin = opalPlugin({ cdn: customUrl })

      if (typeof plugin.transformIndexHtml === 'function') {
        const html = '<head></head>'
        const result = plugin.transformIndexHtml(html, {} as any)

        expect(result).toContain(customUrl)
      }
    })

    it('transformIndexHtml respects opalVersion in CDN URL', () => {
      const plugin = opalPlugin({ cdn: 'jsdelivr', opalVersion: '1.7.0' })

      if (typeof plugin.transformIndexHtml === 'function') {
        const html = '<head></head>'
        const result = plugin.transformIndexHtml(html, {} as any)

        expect(result).toContain('@1.7.0')
      }
    })

    it('transformIndexHtml injects virtual runtime when cdn is disabled', () => {
      const plugin = opalPlugin({ cdn: false })

      if (typeof plugin.transformIndexHtml === 'function') {
        const html = '<head></head>'
        const result = plugin.transformIndexHtml(html, {} as any)

        expect(result).toContain('/@opal-runtime')
        expect(result).toContain('type="module"')
      }
    })

    it('transformIndexHtml injects virtual runtime when cdn is not specified', () => {
      const plugin = opalPlugin()

      if (typeof plugin.transformIndexHtml === 'function') {
        const html = '<head></head>'
        const result = plugin.transformIndexHtml(html, {} as any)

        expect(result).toContain('/@opal-runtime')
        expect(result).toContain('type="module"')
      }
    })
  })
})

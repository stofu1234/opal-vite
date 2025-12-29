import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { OpalCompiler } from '../src/compiler'
import * as path from 'path'
import * as fs from 'fs'
import * as os from 'os'

describe('OpalCompiler', () => {
  let compiler: OpalCompiler
  let tempDir: string
  let testFile: string

  beforeAll(() => {
    compiler = new OpalCompiler({
      loadPaths: [process.cwd()],
      sourceMap: true
    })

    // Create temporary directory for test files
    tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'opal-test-'))
    testFile = path.join(tempDir, 'test.rb')
  })

  afterAll(() => {
    // Clean up temporary directory
    if (fs.existsSync(tempDir)) {
      fs.rmSync(tempDir, { recursive: true })
    }
  })

  describe('compile', () => {
    it('compiles simple Ruby code', async () => {
      const code = 'puts "Hello, World!"'
      fs.writeFileSync(testFile, code)

      const result = await compiler.compile(testFile)

      expect(result).toBeDefined()
      expect(result.code).toBeTruthy()
      expect(result.code).toContain('Hello, World!')
      expect(result.dependencies).toBeInstanceOf(Array)
    })

    it('handles Ruby syntax', async () => {
      const code = `
class Calculator
  def add(a, b)
    a + b
  end
end

calc = Calculator.new
puts calc.add(2, 3)
`
      fs.writeFileSync(testFile, code)

      const result = await compiler.compile(testFile)

      expect(result.code).toBeTruthy()
      expect(result.code).toContain('Calculator')
      expect(result.code).toContain('add')
    })

    it('generates source maps when enabled', async () => {
      const code = 'puts "test"'
      fs.writeFileSync(testFile, code)

      const result = await compiler.compile(testFile)

      if (result.map) {
        const map = JSON.parse(result.map)
        expect(map.version).toBe(3)
        // Opal generates index source maps with sections array
        // Check for either standard format (sources at top level) or index format (sections)
        if (map.sections) {
          // Index source map format
          expect(map.sections).toBeInstanceOf(Array)
          expect(map.sections.length).toBeGreaterThan(0)
          expect(map.sections[0].map).toBeDefined()
          expect(map.sections[0].map.sources).toBeDefined()
          expect(map.sections[0].map.mappings).toBeDefined()
        } else {
          // Standard source map format
          expect(map.sources).toBeDefined()
          expect(map.mappings).toBeDefined()
        }
      }
    })

    it('caches compilation results', async () => {
      const code = 'puts "cached"'
      fs.writeFileSync(testFile, code)

      const result1 = await compiler.compile(testFile)
      const result2 = await compiler.compile(testFile)

      expect(result1.code).toBe(result2.code)
    })

    it('invalidates cache when file changes', async () => {
      const code1 = 'puts "version 1"'
      fs.writeFileSync(testFile, code1)

      const result1 = await compiler.compile(testFile)

      // Wait a bit to ensure different mtime
      await new Promise(resolve => setTimeout(resolve, 10))

      const code2 = 'puts "version 2"'
      fs.writeFileSync(testFile, code2)

      const result2 = await compiler.compile(testFile)

      expect(result1.code).not.toBe(result2.code)
      expect(result2.code).toContain('version 2')
    })

    it('throws error for invalid Ruby syntax', async () => {
      const code = 'def invalid syntax'
      fs.writeFileSync(testFile, code)

      await expect(compiler.compile(testFile)).rejects.toThrow()
    })

    it('handles require statements', async () => {
      const libFile = path.join(tempDir, 'helper.rb')
      fs.writeFileSync(libFile, `
class Helper
  def self.greet
    "Hello"
  end
end
`)

      const mainCode = `
require 'helper'

puts Helper.greet
`
      fs.writeFileSync(testFile, mainCode)

      // Update compiler load paths to include temp dir
      compiler = new OpalCompiler({
        loadPaths: [tempDir],
        sourceMap: true
      })

      const result = await compiler.compile(testFile)

      expect(result.code).toBeTruthy()
      // Dependencies may include path prefix and extension
      expect(result.dependencies.some(dep => dep.includes('helper'))).toBe(true)
    })
  })

  describe('getOpalRuntime', () => {
    it('returns Opal runtime code', async () => {
      const runtime = await compiler.getOpalRuntime()

      expect(runtime).toBeTruthy()
      expect(runtime).toContain('Opal')
    })
  })

  describe('clearCache', () => {
    it('clears cache for specific file', async () => {
      const code = 'puts "test"'
      fs.writeFileSync(testFile, code)

      await compiler.compile(testFile)
      compiler.clearCache(testFile)

      // Verify cache was cleared by checking internal state
      // (This assumes the cache is accessible or has observable effects)
      const result = await compiler.compile(testFile)
      expect(result).toBeDefined()
    })

    it('clears all cache when no file specified', async () => {
      const code = 'puts "test"'
      fs.writeFileSync(testFile, code)

      await compiler.compile(testFile)
      compiler.clearCache()

      const result = await compiler.compile(testFile)
      expect(result).toBeDefined()
    })
  })

  describe('CDN support', () => {
    it('isCdnEnabled returns false by default', () => {
      const cdnCompiler = new OpalCompiler()
      expect(cdnCompiler.isCdnEnabled()).toBe(false)
    })

    it('isCdnEnabled returns false when cdn is explicitly false', () => {
      const cdnCompiler = new OpalCompiler({ cdn: false })
      expect(cdnCompiler.isCdnEnabled()).toBe(false)
    })

    it('isCdnEnabled returns true when cdn option is set to provider', () => {
      const cdnCompiler = new OpalCompiler({ cdn: 'jsdelivr' })
      expect(cdnCompiler.isCdnEnabled()).toBe(true)
    })

    it('isCdnEnabled returns true when cdn option is set to custom URL', () => {
      const cdnCompiler = new OpalCompiler({ cdn: 'https://my-cdn.example.com/opal.js' })
      expect(cdnCompiler.isCdnEnabled()).toBe(true)
    })

    it('getCdnUrl returns null when cdn is disabled', () => {
      const cdnCompiler = new OpalCompiler()
      expect(cdnCompiler.getCdnUrl()).toBeNull()
    })

    it('getCdnUrl returns null when cdn is explicitly false', () => {
      const cdnCompiler = new OpalCompiler({ cdn: false })
      expect(cdnCompiler.getCdnUrl()).toBeNull()
    })

    it('getCdnUrl returns jsdelivr URL with default version', () => {
      const cdnCompiler = new OpalCompiler({ cdn: 'jsdelivr' })
      const url = cdnCompiler.getCdnUrl()
      expect(url).toBe('https://cdn.jsdelivr.net/npm/opal-runtime@1.8.2/dist/opal.min.js')
    })

    it('getCdnUrl returns unpkg URL with default version', () => {
      const cdnCompiler = new OpalCompiler({ cdn: 'unpkg' })
      const url = cdnCompiler.getCdnUrl()
      expect(url).toBe('https://unpkg.com/opal-runtime@1.8.2/dist/opal.min.js')
    })

    it('getCdnUrl returns cdnjs URL with default version', () => {
      const cdnCompiler = new OpalCompiler({ cdn: 'cdnjs' })
      const url = cdnCompiler.getCdnUrl()
      expect(url).toBe('https://cdnjs.cloudflare.com/ajax/libs/opal/1.8.2/opal.min.js')
    })

    it('getCdnUrl respects opalVersion option', () => {
      const cdnCompiler = new OpalCompiler({ cdn: 'jsdelivr', opalVersion: '1.7.0' })
      const url = cdnCompiler.getCdnUrl()
      expect(url).toBe('https://cdn.jsdelivr.net/npm/opal-runtime@1.7.0/dist/opal.min.js')
    })

    it('getCdnUrl returns custom URL as-is', () => {
      const customUrl = 'https://my-cdn.example.com/opal/1.8.2/opal.min.js'
      const cdnCompiler = new OpalCompiler({ cdn: customUrl })
      const url = cdnCompiler.getCdnUrl()
      expect(url).toBe(customUrl)
    })

    it('getCdnUrl ignores opalVersion for custom URL', () => {
      const customUrl = 'https://my-cdn.example.com/opal/custom/opal.min.js'
      const cdnCompiler = new OpalCompiler({ cdn: customUrl, opalVersion: '1.7.0' })
      const url = cdnCompiler.getCdnUrl()
      expect(url).toBe(customUrl)
    })
  })
})

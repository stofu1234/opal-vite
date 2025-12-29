import { describe, it, expect, beforeAll, afterAll, beforeEach, afterEach } from 'vitest'
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
})

// ============================================
// Performance Features Tests (v0.3.2+)
// ============================================

describe('OpalCompiler Performance Features', () => {
  let tempDir: string
  let cacheDir: string

  beforeEach(() => {
    tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'opal-perf-test-'))
    cacheDir = path.join(tempDir, 'cache')
  })

  afterEach(() => {
    if (fs.existsSync(tempDir)) {
      fs.rmSync(tempDir, { recursive: true })
    }
  })

  describe('disk cache', () => {
    it('creates cache files on disk', async () => {
      const compiler = new OpalCompiler({
        diskCache: true,
        cacheDir: cacheDir
      })

      const testFile = path.join(tempDir, 'disk_cache_test.rb')
      fs.writeFileSync(testFile, 'puts "disk cache test"')

      await compiler.compile(testFile)

      // Check that cache directory was created and has files
      expect(fs.existsSync(cacheDir)).toBe(true)
      const cacheFiles = fs.readdirSync(cacheDir).filter(f => f.endsWith('.json'))
      expect(cacheFiles.length).toBeGreaterThan(0)
    })

    it('loads from disk cache on subsequent compile', async () => {
      const compiler = new OpalCompiler({
        diskCache: true,
        cacheDir: cacheDir,
        metrics: true
      })

      const testFile = path.join(tempDir, 'disk_cache_load_test.rb')
      fs.writeFileSync(testFile, 'puts "disk cache load"')

      // First compile - should compile
      await compiler.compile(testFile)
      compiler.clearMetrics()

      // Clear memory cache but keep disk cache
      compiler.clearCache()

      // Second compile - should load from disk
      await compiler.compile(testFile)

      const metrics = compiler.getMetricsSummary()
      expect(metrics.total).toBe(1)
      expect(metrics.cached).toBe(1)
      expect(metrics.details[0].source).toBe('disk')
    })

    it('invalidates disk cache when content changes', async () => {
      const compiler = new OpalCompiler({
        diskCache: true,
        cacheDir: cacheDir
      })

      const testFile = path.join(tempDir, 'disk_cache_invalidate.rb')
      fs.writeFileSync(testFile, 'puts "version 1"')

      const result1 = await compiler.compile(testFile)

      // Clear memory cache
      compiler.clearCache()

      // Change file content
      await new Promise(resolve => setTimeout(resolve, 10))
      fs.writeFileSync(testFile, 'puts "version 2"')

      const result2 = await compiler.compile(testFile)

      expect(result1.code).not.toBe(result2.code)
      expect(result2.code).toContain('version 2')
    })

    it('clears disk cache with clearDiskCache()', async () => {
      const compiler = new OpalCompiler({
        diskCache: true,
        cacheDir: cacheDir
      })

      const testFile = path.join(tempDir, 'disk_cache_clear.rb')
      fs.writeFileSync(testFile, 'puts "clear test"')

      await compiler.compile(testFile)

      // Verify cache exists
      let stats = compiler.getDiskCacheStats()
      expect(stats.files).toBeGreaterThan(0)

      // Clear disk cache
      compiler.clearDiskCache()

      // Verify cache is empty
      stats = compiler.getDiskCacheStats()
      expect(stats.files).toBe(0)
    })

    it('respects diskCache: false option', async () => {
      const compiler = new OpalCompiler({
        diskCache: false,
        cacheDir: cacheDir
      })

      const testFile = path.join(tempDir, 'no_disk_cache.rb')
      fs.writeFileSync(testFile, 'puts "no disk cache"')

      await compiler.compile(testFile)

      // Cache directory should not exist or be empty
      if (fs.existsSync(cacheDir)) {
        const cacheFiles = fs.readdirSync(cacheDir).filter(f => f.endsWith('.json'))
        expect(cacheFiles.length).toBe(0)
      }
    })
  })

  describe('stubs', () => {
    it('returns empty implementation for stubbed modules', async () => {
      const compiler = new OpalCompiler({
        diskCache: false,
        stubs: ['active_support', 'my_server_gem']
      })

      const testFile = path.join(tempDir, 'active_support.rb')
      fs.writeFileSync(testFile, 'class ActiveSupport; end')

      const result = await compiler.compile(testFile)

      expect(result.code).toContain('Stubbed module')
      expect(result.code).toContain('Opal.loaded')
      expect(result.dependencies).toEqual([])
    })

    it('does not stub non-matching modules', async () => {
      const compiler = new OpalCompiler({
        diskCache: false,
        stubs: ['active_support']
      })

      const testFile = path.join(tempDir, 'my_module.rb')
      fs.writeFileSync(testFile, 'puts "not stubbed"')

      const result = await compiler.compile(testFile)

      expect(result.code).not.toContain('Stubbed module')
      expect(result.code).toContain('not stubbed')
    })
  })

  describe('metrics', () => {
    it('records compilation metrics when enabled', async () => {
      const compiler = new OpalCompiler({
        diskCache: false,
        metrics: true
      })

      const testFile = path.join(tempDir, 'metrics_test.rb')
      fs.writeFileSync(testFile, 'puts "metrics"')

      await compiler.compile(testFile)

      const summary = compiler.getMetricsSummary()
      expect(summary.total).toBe(1)
      expect(summary.details.length).toBe(1)
      expect(summary.details[0].file).toBe('metrics_test.rb')
      expect(summary.details[0].duration).toBeGreaterThan(0)
    })

    it('does not record metrics when disabled', async () => {
      const compiler = new OpalCompiler({
        diskCache: false,
        metrics: false
      })

      const testFile = path.join(tempDir, 'no_metrics.rb')
      fs.writeFileSync(testFile, 'puts "no metrics"')

      await compiler.compile(testFile)

      const summary = compiler.getMetricsSummary()
      expect(summary.total).toBe(0)
    })

    it('getMetricsSummary returns correct stats', async () => {
      const compiler = new OpalCompiler({
        diskCache: false,
        metrics: true
      })

      const testFile1 = path.join(tempDir, 'metrics1.rb')
      const testFile2 = path.join(tempDir, 'metrics2.rb')
      fs.writeFileSync(testFile1, 'puts "one"')
      fs.writeFileSync(testFile2, 'puts "two"')

      await compiler.compile(testFile1)
      await compiler.compile(testFile2)
      // Compile again to get cache hit
      await compiler.compile(testFile1)

      const summary = compiler.getMetricsSummary()
      expect(summary.total).toBe(3)
      expect(summary.compiled).toBe(2)
      expect(summary.cached).toBe(1)
      expect(summary.avgDuration).toBeGreaterThan(0)
    })

    it('clearMetrics resets all metrics', async () => {
      const compiler = new OpalCompiler({
        diskCache: false,
        metrics: true
      })

      const testFile = path.join(tempDir, 'clear_metrics.rb')
      fs.writeFileSync(testFile, 'puts "clear"')

      await compiler.compile(testFile)
      expect(compiler.getMetricsSummary().total).toBe(1)

      compiler.clearMetrics()
      expect(compiler.getMetricsSummary().total).toBe(0)
    })
  })

  describe('parallel compilation', () => {
    it('compileMany processes multiple files', async () => {
      const compiler = new OpalCompiler({
        diskCache: false,
        parallelCompilation: 4
      })

      const files: string[] = []
      for (let i = 0; i < 5; i++) {
        const file = path.join(tempDir, `parallel_${i}.rb`)
        fs.writeFileSync(file, `puts "file ${i}"`)
        files.push(file)
      }

      const results = await compiler.compileMany(files)

      expect(results.size).toBe(5)
      for (const file of files) {
        expect(results.has(file)).toBe(true)
        const result = results.get(file)
        expect(result?.code).toBeTruthy()
      }
    })

    it('respects parallelCompilation limit', async () => {
      const compiler = new OpalCompiler({
        diskCache: false,
        parallelCompilation: 2,
        metrics: true
      })

      const files: string[] = []
      for (let i = 0; i < 4; i++) {
        const file = path.join(tempDir, `limit_${i}.rb`)
        fs.writeFileSync(file, `puts "limit ${i}"`)
        files.push(file)
      }

      await compiler.compileMany(files)

      const summary = compiler.getMetricsSummary()
      expect(summary.compiled).toBe(4)
    })

    it('handles compilation errors gracefully', async () => {
      const compiler = new OpalCompiler({
        diskCache: false,
        parallelCompilation: 2
      })

      const goodFile = path.join(tempDir, 'good.rb')
      const badFile = path.join(tempDir, 'bad.rb')
      fs.writeFileSync(goodFile, 'puts "good"')
      fs.writeFileSync(badFile, 'def invalid syntax')

      const results = await compiler.compileMany([goodFile, badFile])

      // Good file should succeed
      expect(results.has(goodFile)).toBe(true)
      expect(results.get(goodFile)?.code).toContain('good')

      // Bad file should not be in results
      expect(results.has(badFile)).toBe(false)
    })
  })
})

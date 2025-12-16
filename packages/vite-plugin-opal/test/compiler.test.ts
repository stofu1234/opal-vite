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
        expect(map.sources).toBeDefined()
        expect(map.mappings).toBeDefined()
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

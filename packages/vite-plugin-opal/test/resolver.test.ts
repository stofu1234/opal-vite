import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { OpalResolver } from '../src/resolver'
import * as path from 'path'
import * as fs from 'fs'
import * as os from 'os'

describe('OpalResolver', () => {
  let resolver: OpalResolver
  let tempDir: string

  beforeAll(() => {
    // Create temporary directory structure
    tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'opal-resolver-test-'))

    // Create test files
    fs.writeFileSync(path.join(tempDir, 'main.rb'), 'puts "main"')
    fs.mkdirSync(path.join(tempDir, 'lib'))
    fs.writeFileSync(path.join(tempDir, 'lib', 'helper.rb'), 'puts "helper"')
    fs.mkdirSync(path.join(tempDir, 'lib', 'utils'))
    fs.writeFileSync(path.join(tempDir, 'lib', 'utils', 'formatter.rb'), 'puts "formatter"')

    resolver = new OpalResolver({
      loadPaths: [tempDir, path.join(tempDir, 'lib')]
    })
  })

  afterAll(() => {
    // Clean up
    if (fs.existsSync(tempDir)) {
      fs.rmSync(tempDir, { recursive: true })
    }
  })

  describe('resolve', () => {
    it('resolves absolute paths', async () => {
      const absolutePath = path.join(tempDir, 'main.rb')
      const result = await resolver.resolve(absolutePath)

      expect(result).toBe(absolutePath)
    })

    it('resolves relative paths from importer', async () => {
      const importer = path.join(tempDir, 'main.rb')
      const result = await resolver.resolve('./lib/helper.rb', importer)

      expect(result).toBe(path.join(tempDir, 'lib', 'helper.rb'))
    })

    it('resolves from load paths', async () => {
      const result = await resolver.resolve('helper')

      expect(result).toBe(path.join(tempDir, 'lib', 'helper.rb'))
    })

    it('resolves with .rb extension', async () => {
      const result = await resolver.resolve('helper.rb')

      expect(result).toBe(path.join(tempDir, 'lib', 'helper.rb'))
    })

    it('resolves nested paths', async () => {
      const result = await resolver.resolve('utils/formatter')

      expect(result).toBe(path.join(tempDir, 'lib', 'utils', 'formatter.rb'))
    })

    it('returns null for non-existent files', async () => {
      const result = await resolver.resolve('nonexistent')

      expect(result).toBeNull()
    })

    it('caches resolution results', async () => {
      const id1 = await resolver.resolve('helper')
      const id2 = await resolver.resolve('helper')

      expect(id1).toBe(id2)
      expect(id1).toBeTruthy()
    })
  })

  describe('clearCache', () => {
    it('clears cache for specific file', async () => {
      const resolved = await resolver.resolve('helper')
      expect(resolved).toBeTruthy()

      resolver.clearCache(resolved!)

      // Resolve again after cache clear
      const resolved2 = await resolver.resolve('helper')
      expect(resolved2).toBe(resolved)
    })

    it('clears all cache when no file specified', async () => {
      await resolver.resolve('helper')
      await resolver.resolve('utils/formatter')

      resolver.clearCache()

      // Resolving again should work
      const result = await resolver.resolve('helper')
      expect(result).toBeTruthy()
    })
  })

  describe('edge cases', () => {
    it('handles paths with special characters', async () => {
      const specialFile = path.join(tempDir, 'special-file.rb')
      fs.writeFileSync(specialFile, 'puts "special"')

      const result = await resolver.resolve('special-file')

      expect(result).toBe(specialFile)

      // Clean up
      fs.unlinkSync(specialFile)
    })

    it('handles case-sensitive file systems', async () => {
      const result = await resolver.resolve('Helper')

      // On case-sensitive systems, this should fail
      // On case-insensitive systems, it might succeed
      // We just verify it doesn't crash
      expect(result === null || typeof result === 'string').toBe(true)
    })
  })
})

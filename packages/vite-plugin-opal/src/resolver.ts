import * as path from 'path'
import * as fs from 'fs/promises'
import type { OpalPluginOptions } from './types'

export class OpalResolver {
  private options: Required<OpalPluginOptions>
  private loadPaths: string[]
  private resolveCache: Map<string, string | null> = new Map()

  constructor(options: OpalPluginOptions = {}) {
    this.options = {
      gemPath: options.gemPath || 'opal-vite',
      sourceMap: options.sourceMap !== false,
      loadPaths: options.loadPaths || ['./src'],
      arityCheck: options.arityCheck || false,
      freezing: options.freezing !== false,
      debug: options.debug || false
    }
    this.loadPaths = this.options.loadPaths
  }

  /**
   * Resolve a Ruby file import
   * Supports:
   * - Absolute paths: /path/to/file.rb
   * - Relative paths: ./file.rb, ../file.rb
   * - Load path resolution: file (searches in loadPaths)
   */
  async resolve(id: string, importer?: string): Promise<string | null> {
    // Check cache first
    const cacheKey = `${id}|${importer || ''}`
    if (this.resolveCache.has(cacheKey)) {
      return this.resolveCache.get(cacheKey)!
    }

    let resolved: string | null = null

    // Only resolve .rb files or files without extension
    if (id.endsWith('.rb') || !this.hasExtension(id)) {
      // Try different resolution strategies
      resolved = await this.resolveAbsolute(id) ||
                 await this.resolveRelative(id, importer) ||
                 await this.resolveFromLoadPaths(id)
    }

    // Cache the result
    this.resolveCache.set(cacheKey, resolved)

    if (resolved && this.options.debug) {
      console.log(`[vite-plugin-opal] Resolved: ${id} -> ${resolved}`)
    }

    return resolved
  }

  /**
   * Clear the resolution cache
   */
  clearCache(filePath?: string): void {
    if (filePath) {
      // Clear cache entries related to this file
      for (const [key, value] of this.resolveCache.entries()) {
        if (value === filePath || key.startsWith(filePath)) {
          this.resolveCache.delete(key)
        }
      }
    } else {
      this.resolveCache.clear()
    }
  }

  /**
   * Get all load paths
   */
  getLoadPaths(): string[] {
    return [...this.loadPaths]
  }

  /**
   * Add a load path
   */
  addLoadPath(loadPath: string): void {
    if (!this.loadPaths.includes(loadPath)) {
      this.loadPaths.push(loadPath)
      this.clearCache() // Clear cache when load paths change
    }
  }

  private async resolveAbsolute(id: string): Promise<string | null> {
    if (!path.isAbsolute(id)) {
      return null
    }

    // Try as-is
    if (await this.fileExists(id)) {
      return id
    }

    // Try with .rb extension
    if (!id.endsWith('.rb')) {
      const withExt = `${id}.rb`
      if (await this.fileExists(withExt)) {
        return withExt
      }
    }

    return null
  }

  private async resolveRelative(id: string, importer?: string): Promise<string | null> {
    if (!id.startsWith('.') || !importer) {
      return null
    }

    const importerDir = path.dirname(importer)
    const resolved = path.resolve(importerDir, id)

    // Try as-is
    if (await this.fileExists(resolved)) {
      return resolved
    }

    // Try with .rb extension
    if (!id.endsWith('.rb')) {
      const withExt = `${resolved}.rb`
      if (await this.fileExists(withExt)) {
        return withExt
      }
    }

    return null
  }

  private async resolveFromLoadPaths(id: string): Promise<string | null> {
    // Remove .rb extension for load path search
    const baseId = id.endsWith('.rb') ? id.slice(0, -3) : id

    for (const loadPath of this.loadPaths) {
      // Try with original id
      const fullPath = path.resolve(loadPath, id)
      if (await this.fileExists(fullPath)) {
        return fullPath
      }

      // Try with .rb extension
      const withExt = path.resolve(loadPath, `${baseId}.rb`)
      if (await this.fileExists(withExt)) {
        return withExt
      }

      // Try as a directory with index.rb
      const indexPath = path.resolve(loadPath, baseId, 'index.rb')
      if (await this.fileExists(indexPath)) {
        return indexPath
      }
    }

    return null
  }

  private async fileExists(filePath: string): Promise<boolean> {
    try {
      const stat = await fs.stat(filePath)
      return stat.isFile()
    } catch {
      return false
    }
  }

  private hasExtension(filePath: string): boolean {
    const ext = path.extname(filePath)
    return ext !== ''
  }
}

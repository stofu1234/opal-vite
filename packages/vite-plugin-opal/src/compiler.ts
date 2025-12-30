import { spawn } from 'child_process'
import * as fs from 'fs/promises'
import { accessSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'fs'
import * as path from 'path'
import * as crypto from 'crypto'
import type { OpalPluginOptions, CompileResult, CacheEntry, OpalCompilationError } from './types'

/**
 * Parse Opal/Ruby compilation error output into structured error information
 */
function parseRubyError(stderr: string, filePath: string): OpalCompilationError {
  const lines = stderr.trim().split('\n')
  const error: OpalCompilationError = {
    message: stderr.trim(),
    file: filePath,
    rawOutput: stderr
  }

  // Try to extract line number from Ruby error format: "file.rb:123: error message"
  // or "file.rb:123:in `method': error message"
  for (const line of lines) {
    const lineMatch = line.match(/^(.+?):(\d+)(?::(\d+))?(?::in `[^']+')?\s*[:\-]?\s*(.*)/)
    if (lineMatch) {
      const [, matchedFile, lineNum, colNum, msg] = lineMatch
      if (matchedFile.endsWith('.rb') || matchedFile.includes(filePath)) {
        error.file = matchedFile
        error.line = parseInt(lineNum, 10)
        if (colNum) {
          error.column = parseInt(colNum, 10)
        }
        error.message = msg || line
        break
      }
    }
  }

  // Extract error type from Ruby exceptions
  const typeMatch = stderr.match(/(\w+Error|\w+Exception):\s*(.+)/m)
  if (typeMatch) {
    error.errorType = typeMatch[1]
    if (!error.message || error.message === stderr.trim()) {
      error.message = typeMatch[2].trim()
    }
  }

  // Check for common Opal-specific errors
  if (stderr.includes('SyntaxError')) {
    error.errorType = 'SyntaxError'
    const syntaxMatch = stderr.match(/SyntaxError:\s*(.+?)(?:\n|$)/)
    if (syntaxMatch) {
      error.message = syntaxMatch[1]
    }
  } else if (stderr.includes('NameError')) {
    error.errorType = 'NameError'
    const nameMatch = stderr.match(/NameError:\s*(.+?)(?:\n|$)/)
    if (nameMatch) {
      error.message = nameMatch[1]
    }
  } else if (stderr.includes('LoadError')) {
    error.errorType = 'LoadError'
    const loadMatch = stderr.match(/LoadError:\s*(.+?)(?:\n|$)/)
    if (loadMatch) {
      error.message = loadMatch[1]
    }
    // Extract the file that couldn't be loaded
    const requireMatch = stderr.match(/cannot load such file\s*--\s*(.+)/)
    if (requireMatch) {
      error.hint = `Check that '${requireMatch[1]}' exists and is in your load paths`
    }
  }

  return error
}

/**
 * Format compilation error for display in terminal/browser
 */
function formatCompilationError(error: OpalCompilationError): string {
  const parts: string[] = []

  // Header with error type
  const errorType = error.errorType || 'CompilationError'
  parts.push(`\x1b[31m✖ Opal ${errorType}\x1b[0m`)

  // Location info
  if (error.file) {
    let location = `  \x1b[36m→ ${error.file}\x1b[0m`
    if (error.line) {
      location += `\x1b[33m:${error.line}\x1b[0m`
      if (error.column) {
        location += `\x1b[33m:${error.column}\x1b[0m`
      }
    }
    parts.push(location)
  }

  // Error message
  parts.push(`  \x1b[37m${error.message}\x1b[0m`)

  // Hint if available
  if (error.hint) {
    parts.push(`  \x1b[33m💡 ${error.hint}\x1b[0m`)
  }

  return parts.join('\n')
}

/**
 * Metrics for a single compilation
 */
interface CompileMetrics {
  file: string
  duration: number
  cacheHit: boolean
  source: 'memory' | 'disk' | 'compile'
}

/**
 * Disk cache entry format
 */
interface DiskCacheEntry {
  version: string
  contentHash: string
  mtime: number
  result: CompileResult
}

const CACHE_VERSION = '1.0.0'

// Default Opal version for CDN
const DEFAULT_OPAL_VERSION = '1.8.2'

// CDN URL templates
const CDN_URLS: Record<string, string> = {
  unpkg: 'https://unpkg.com/opal-runtime@{version}/dist/opal.min.js',
  jsdelivr: 'https://cdn.jsdelivr.net/npm/opal-runtime@{version}/dist/opal.min.js',
  cdnjs: 'https://cdnjs.cloudflare.com/ajax/libs/opal/{version}/opal.min.js'
}

export class OpalCompiler {
  private options: Required<OpalPluginOptions> & { cdn: string | false; opalVersion: string }
  private cache: Map<string, CacheEntry> = new Map()
  private runtimeCache: string | null = null
  private useBundler: boolean
  private cacheDir: string
  private metrics: CompileMetrics[] = []
  private compilationQueue: Promise<void> = Promise.resolve()
  private activeCompilations = 0

  constructor(options: OpalPluginOptions = {}) {
    this.options = {
      gemPath: options.gemPath || 'opal-vite',
      sourceMap: options.sourceMap !== false,
      loadPaths: options.loadPaths || ['./src'],
      arityCheck: options.arityCheck || false,
      freezing: options.freezing !== false,
      debug: options.debug || false,
      useBundler: options.useBundler !== undefined ? options.useBundler : this.detectGemfile(),
      includeConcerns: options.includeConcerns !== false,
      // Performance options (v0.3.2+)
      diskCache: options.diskCache !== false,
      cacheDir: options.cacheDir || '',
      stubs: options.stubs || [],
      parallelCompilation: options.parallelCompilation || 4,
      metrics: options.metrics || false,
      // CDN options (v0.3.5+)
      cdn: options.cdn || false,
      opalVersion: options.opalVersion || DEFAULT_OPAL_VERSION
    }
    this.useBundler = this.options.useBundler
    this.cacheDir = this.resolveCacheDir()

    // Ensure cache directory exists
    if (this.options.diskCache) {
      this.ensureCacheDir()
    }

    if (this.options.debug) {
      console.log(`[vite-plugin-opal] Using bundler: ${this.useBundler}`)
      console.log(`[vite-plugin-opal] Working directory: ${process.cwd()}`)
      console.log(`[vite-plugin-opal] Include concerns: ${this.options.includeConcerns}`)
      console.log(`[vite-plugin-opal] Disk cache: ${this.options.diskCache ? 'enabled' : 'disabled'}`)
      if (this.options.diskCache) {
        console.log(`[vite-plugin-opal] Cache directory: ${this.cacheDir}`)
      }
      if (this.options.stubs.length > 0) {
        console.log(`[vite-plugin-opal] Stubs: ${this.options.stubs.join(', ')}`)
      }
      console.log(`[vite-plugin-opal] Parallel compilation: ${this.options.parallelCompilation}`)
      if (this.options.cdn) {
        console.log(`[vite-plugin-opal] CDN mode: ${this.options.cdn}`)
        console.log(`[vite-plugin-opal] CDN URL: ${this.getCdnUrl()}`)
      }
    }
  }

  private resolveCacheDir(): string {
    if (this.options.cacheDir) {
      return path.resolve(process.cwd(), this.options.cacheDir)
    }
    // Default: node_modules/.cache/opal-vite
    return path.resolve(process.cwd(), 'node_modules', '.cache', 'opal-vite')
  }

  private ensureCacheDir(): void {
    try {
      if (!existsSync(this.cacheDir)) {
        mkdirSync(this.cacheDir, { recursive: true })
        this.log(`Created cache directory: ${this.cacheDir}`)
      }
    } catch (e) {
      this.log(`Warning: Could not create cache directory: ${e}`)
    }
  }

  private getCacheKey(filePath: string): string {
    // Create a safe filename from the file path
    const normalized = path.resolve(filePath)
    return crypto.createHash('md5').update(normalized).digest('hex')
  }

  private getContentHash(content: string): string {
    return crypto.createHash('md5').update(content).digest('hex')
  }

  private getDiskCachePath(filePath: string): string {
    return path.join(this.cacheDir, `${this.getCacheKey(filePath)}.json`)
  }

  private async loadFromDiskCache(filePath: string, contentHash: string): Promise<CompileResult | null> {
    if (!this.options.diskCache) return null

    const cachePath = this.getDiskCachePath(filePath)
    try {
      if (!existsSync(cachePath)) return null

      const cacheContent = readFileSync(cachePath, 'utf-8')
      const entry: DiskCacheEntry = JSON.parse(cacheContent)

      // Validate cache entry
      if (entry.version !== CACHE_VERSION) {
        this.log(`Disk cache version mismatch for ${filePath}`)
        return null
      }

      if (entry.contentHash !== contentHash) {
        this.log(`Disk cache content hash mismatch for ${filePath}`)
        return null
      }

      this.log(`Disk cache hit: ${filePath}`)
      return entry.result
    } catch (e) {
      // Cache file is invalid or corrupted
      this.log(`Disk cache read error for ${filePath}: ${e}`)
      return null
    }
  }

  private saveToDiskCache(filePath: string, contentHash: string, mtime: number, result: CompileResult): void {
    if (!this.options.diskCache) return

    const cachePath = this.getDiskCachePath(filePath)
    try {
      const entry: DiskCacheEntry = {
        version: CACHE_VERSION,
        contentHash,
        mtime,
        result
      }
      writeFileSync(cachePath, JSON.stringify(entry), 'utf-8')
      this.log(`Disk cache saved: ${filePath}`)
    } catch (e) {
      this.log(`Disk cache write error for ${filePath}: ${e}`)
    }
  }

  /**
   * Check if CDN mode is enabled
   */
  isCdnEnabled(): boolean {
    return !!this.options.cdn
  }

  /**
   * Get the CDN URL for Opal runtime
   */
  getCdnUrl(): string | null {
    const cdn = this.options.cdn
    if (!cdn) return null

    // Check if it's a known CDN provider
    if (cdn in CDN_URLS) {
      return CDN_URLS[cdn].replace('{version}', this.options.opalVersion)
    }

    // Assume it's a custom URL
    return cdn
  }

  private detectGemfile(): boolean {
    try {
      const gemfilePath = path.join(process.cwd(), 'Gemfile')
      accessSync(gemfilePath)
      return true
    } catch {
      return false
    }
  }

  async compile(filePath: string): Promise<CompileResult> {
    const startTime = this.options.metrics ? performance.now() : 0

    // Check if this is a stubbed module
    const stubResult = this.checkStub(filePath)
    if (stubResult) {
      this.recordMetrics(filePath, startTime, true, 'memory')
      return stubResult
    }

    // Read file content for hash-based cache validation
    let fileContent: string
    let stat: { mtimeMs: number }
    try {
      fileContent = await fs.readFile(filePath, 'utf-8')
      stat = await fs.stat(filePath)
    } catch (e) {
      throw new Error(`Failed to read file: ${filePath}`)
    }

    const contentHash = this.getContentHash(fileContent)

    // Check memory cache first
    const cached = this.cache.get(filePath)
    if (cached) {
      if (stat.mtimeMs <= cached.mtime) {
        this.log(`Memory cache hit: ${filePath}`)
        this.recordMetrics(filePath, startTime, true, 'memory')
        return {
          code: cached.code,
          map: cached.map,
          dependencies: cached.dependencies
        }
      }
      // Cache is stale, remove it
      this.cache.delete(filePath)
    }

    // Check disk cache
    const diskCached = await this.loadFromDiskCache(filePath, contentHash)
    if (diskCached) {
      // Update memory cache
      this.cache.set(filePath, {
        ...diskCached,
        mtime: stat.mtimeMs
      })
      this.recordMetrics(filePath, startTime, true, 'disk')
      return diskCached
    }

    // Compile with concurrency control
    this.log(`Compiling: ${filePath}`)
    const result = await this.compileWithConcurrencyControl(filePath)

    // Cache the result in memory
    this.cache.set(filePath, {
      ...result,
      mtime: stat.mtimeMs
    })

    // Cache the result on disk
    this.saveToDiskCache(filePath, contentHash, stat.mtimeMs, result)

    this.recordMetrics(filePath, startTime, false, 'compile')
    return result
  }

  /**
   * Compile multiple files in parallel with concurrency control
   */
  async compileMany(filePaths: string[]): Promise<Map<string, CompileResult>> {
    const results = new Map<string, CompileResult>()

    // Process files in batches based on parallelCompilation setting
    const batchSize = this.options.parallelCompilation
    for (let i = 0; i < filePaths.length; i += batchSize) {
      const batch = filePaths.slice(i, i + batchSize)
      const batchResults = await Promise.all(
        batch.map(async (filePath) => {
          try {
            const result = await this.compile(filePath)
            return { filePath, result, error: null }
          } catch (e) {
            return { filePath, result: null, error: e }
          }
        })
      )

      for (const { filePath, result, error } of batchResults) {
        if (result) {
          results.set(filePath, result)
        } else {
          this.log(`Compilation failed for ${filePath}: ${error}`)
        }
      }
    }

    return results
  }

  private async compileWithConcurrencyControl(filePath: string): Promise<CompileResult> {
    // Wait if we're at the concurrency limit
    while (this.activeCompilations >= this.options.parallelCompilation) {
      await new Promise(resolve => setTimeout(resolve, 10))
    }

    this.activeCompilations++
    try {
      return await this.compileViaRuby(filePath)
    } finally {
      this.activeCompilations--
    }
  }

  private checkStub(filePath: string): CompileResult | null {
    if (this.options.stubs.length === 0) return null

    const fileName = path.basename(filePath, '.rb')
    const isStubbed = this.options.stubs.some(stub => {
      // Match exact name or pattern
      if (stub === fileName) return true
      // Match as a path component (e.g., 'active_support' matches any active_support/*.rb)
      if (filePath.includes(`/${stub}/`) || filePath.includes(`/${stub}.rb`)) return true
      return false
    })

    if (isStubbed) {
      this.log(`Stubbed module: ${filePath}`)
      return {
        code: '// Stubbed module\nOpal.loaded(["' + fileName + '"]);\n',
        map: undefined,
        dependencies: []
      }
    }

    return null
  }

  private recordMetrics(filePath: string, startTime: number, cacheHit: boolean, source: 'memory' | 'disk' | 'compile'): void {
    if (!this.options.metrics) return

    const duration = performance.now() - startTime
    this.metrics.push({
      file: path.basename(filePath),
      duration,
      cacheHit,
      source
    })
  }

  /**
   * Get compilation metrics summary
   */
  getMetricsSummary(): { total: number; cached: number; compiled: number; avgDuration: number; details: CompileMetrics[] } {
    const total = this.metrics.length
    const cached = this.metrics.filter(m => m.cacheHit).length
    const compiled = total - cached
    const avgDuration = total > 0
      ? this.metrics.reduce((sum, m) => sum + m.duration, 0) / total
      : 0

    return {
      total,
      cached,
      compiled,
      avgDuration: Math.round(avgDuration * 100) / 100,
      details: [...this.metrics]
    }
  }

  /**
   * Print metrics summary to console
   */
  printMetricsSummary(): void {
    const summary = this.getMetricsSummary()
    console.log('\n[vite-plugin-opal] Compilation Metrics:')
    console.log(`  Total files: ${summary.total}`)
    console.log(`  Cache hits: ${summary.cached} (${Math.round(summary.cached / summary.total * 100) || 0}%)`)
    console.log(`  Compiled: ${summary.compiled}`)
    console.log(`  Avg duration: ${summary.avgDuration}ms`)

    if (this.options.debug && summary.details.length > 0) {
      console.log('\n  Details:')
      for (const m of summary.details) {
        console.log(`    ${m.file}: ${Math.round(m.duration)}ms (${m.source})`)
      }
    }
  }

  /**
   * Clear metrics
   */
  clearMetrics(): void {
    this.metrics = []
  }

  async getOpalRuntime(): Promise<string> {
    if (this.runtimeCache) {
      return this.runtimeCache
    }

    this.log('Loading Opal runtime')
    const runtime = await this.getRuntimeViaRuby()
    this.runtimeCache = runtime
    return runtime
  }

  clearCache(filePath?: string, clearDisk = false): void {
    if (filePath) {
      this.cache.delete(filePath)
      if (clearDisk && this.options.diskCache) {
        try {
          const cachePath = this.getDiskCachePath(filePath)
          if (existsSync(cachePath)) {
            const fsSync = require('fs')
            fsSync.unlinkSync(cachePath)
          }
        } catch (e) {
          this.log(`Failed to clear disk cache for ${filePath}: ${e}`)
        }
      }
      this.log(`Cache cleared: ${filePath}`)
    } else {
      this.cache.clear()
      if (clearDisk && this.options.diskCache) {
        this.clearDiskCache()
      }
      this.log('Cache cleared (all)')
    }
  }

  /**
   * Clear all disk cache files
   */
  clearDiskCache(): void {
    if (!this.options.diskCache) return

    try {
      const fsSync = require('fs')
      if (existsSync(this.cacheDir)) {
        const files = fsSync.readdirSync(this.cacheDir)
        for (const file of files) {
          if (file.endsWith('.json')) {
            fsSync.unlinkSync(path.join(this.cacheDir, file))
          }
        }
        this.log(`Cleared ${files.length} disk cache files`)
      }
    } catch (e) {
      this.log(`Failed to clear disk cache: ${e}`)
    }
  }

  /**
   * Get disk cache statistics
   */
  getDiskCacheStats(): { files: number; size: number } {
    if (!this.options.diskCache || !existsSync(this.cacheDir)) {
      return { files: 0, size: 0 }
    }

    try {
      const fsSync = require('fs')
      const files = fsSync.readdirSync(this.cacheDir)
        .filter((f: string) => f.endsWith('.json'))
      let totalSize = 0
      for (const file of files) {
        const stat = fsSync.statSync(path.join(this.cacheDir, file))
        totalSize += stat.size
      }
      return { files: files.length, size: totalSize }
    } catch (e) {
      return { files: 0, size: 0 }
    }
  }

  private async compileViaRuby(filePath: string): Promise<CompileResult> {
    return new Promise((resolve, reject) => {
      let command: string
      let args: string[]

      if (this.useBundler) {
        command = 'bundle'
        args = [
          'exec', 'ruby',
          '-r', 'opal-vite',
          '-e', this.getCompilerScript(),
          filePath
        ]
      } else {
        const gemLibPath = this.resolveGemLibPath()
        command = 'ruby'
        args = [
          '-I', gemLibPath,
          '-e', `$LOAD_PATH.unshift('${gemLibPath}'); require 'opal-vite'; ${this.getCompilerScript()}`,
          filePath
        ]
      }

      this.log(`Spawning Ruby: ${command} ${args.join(' ')}`)

      const ruby = spawn(command, args, {
        cwd: process.cwd()
      })

      let stdout = ''
      let stderr = ''

      ruby.stdout.on('data', (data) => {
        stdout += data.toString()
      })

      ruby.stderr.on('data', (data) => {
        stderr += data.toString()
      })

      ruby.on('close', (code) => {
        if (code !== 0) {
          const parsedError = parseRubyError(stderr, filePath)
          const formattedMessage = formatCompilationError(parsedError)
          console.error(formattedMessage)

          // Create an error with structured information for Vite
          const error = new Error(parsedError.message) as Error & OpalCompilationError
          error.file = parsedError.file
          error.line = parsedError.line
          error.column = parsedError.column
          error.errorType = parsedError.errorType
          error.hint = parsedError.hint
          error.rawOutput = parsedError.rawOutput

          reject(error)
          return
        }

        try {
          const result = JSON.parse(stdout)
          resolve(result)
        } catch (e) {
          const parseError = new Error(`Failed to parse compiler output: ${e}`)
          console.error('\x1b[31m✖ Opal Compiler Output Parse Error\x1b[0m')
          console.error(`  \x1b[36m→ ${filePath}\x1b[0m`)
          console.error(`  \x1b[37mUnexpected output from Ruby compiler\x1b[0m`)
          if (this.options.debug) {
            console.error(`  \x1b[90mRaw output: ${stdout.substring(0, 500)}...\x1b[0m`)
          }
          reject(parseError)
        }
      })

      ruby.on('error', (err) => {
        console.error('\x1b[31m✖ Ruby Process Error\x1b[0m')
        console.error(`  \x1b[37m${err.message}\x1b[0m`)
        console.error(`  \x1b[33m💡 Make sure Ruby and Opal are installed correctly\x1b[0m`)
        reject(new Error(`Failed to spawn Ruby process: ${err.message}`))
      })
    })
  }

  private async getRuntimeViaRuby(): Promise<string> {
    return new Promise((resolve, reject) => {
      let command: string
      let args: string[]

      if (this.useBundler) {
        command = 'bundle'
        args = [
          'exec', 'ruby',
          '-r', 'opal-vite',
          '-e', 'puts Opal::Vite::Compiler.runtime_code'
        ]
      } else {
        const gemLibPath = this.resolveGemLibPath()
        command = 'ruby'
        args = [
          '-I', gemLibPath,
          '-e', `$LOAD_PATH.unshift('${gemLibPath}'); require 'opal-vite'; puts Opal::Vite::Compiler.runtime_code`
        ]
      }

      const ruby = spawn(command, args, {
        cwd: process.cwd()
      })

      let stdout = ''
      let stderr = ''

      ruby.stdout.on('data', (data) => {
        stdout += data.toString()
      })

      ruby.stderr.on('data', (data) => {
        stderr += data.toString()
      })

      ruby.on('close', (code) => {
        if (code === 0) {
          resolve(stdout)
        } else {
          reject(new Error(`Failed to get Opal runtime:\n${stderr}`))
        }
      })

      ruby.on('error', (err) => {
        reject(new Error(`Failed to spawn Ruby process: ${err.message}`))
      })
    })
  }

  private getCompilerScript(): string {
    const includeConcerns = this.options.includeConcerns
    const sourceMap = this.options.sourceMap
    const stubs = JSON.stringify(this.options.stubs)
    // Note: opal-vite is already required via -r flag or -I flag
    // The $LOAD_PATH is set up by -I option, so require 'opal-vite' will find it
    return `
      file_path = ARGV[0]
      stubs = ${stubs}
      Opal::Vite.compile_for_vite(file_path, include_concerns: ${includeConcerns}, source_map: ${sourceMap}, stubs: stubs)
    `.trim()
  }

  private resolveGemLibPath(): string {
    // Try to resolve the gem path
    // In development, this points to our local gem
    // In production, bundler will handle it
    if (this.options.gemPath.startsWith('.') || this.options.gemPath.startsWith('/')) {
      return path.resolve(this.options.gemPath, 'lib')
    }
    return this.options.gemPath
  }

  private log(message: string): void {
    if (this.options.debug) {
      console.log(`[vite-plugin-opal] ${message}`)
    }
  }
}

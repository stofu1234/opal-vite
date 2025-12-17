import { spawn } from 'child_process'
import * as fs from 'fs/promises'
import { accessSync } from 'fs'
import * as path from 'path'
import type { OpalPluginOptions, CompileResult, CacheEntry } from './types'

export class OpalCompiler {
  private options: Required<OpalPluginOptions>
  private cache: Map<string, CacheEntry> = new Map()
  private runtimeCache: string | null = null
  private useBundler: boolean

  constructor(options: OpalPluginOptions = {}) {
    this.options = {
      gemPath: options.gemPath || 'opal-vite',
      sourceMap: options.sourceMap !== false,
      loadPaths: options.loadPaths || ['./src'],
      arityCheck: options.arityCheck || false,
      freezing: options.freezing !== false,
      debug: options.debug || false,
      useBundler: options.useBundler !== undefined ? options.useBundler : this.detectGemfile(),
      includeConcerns: options.includeConcerns !== false
    }
    this.useBundler = this.options.useBundler

    if (this.options.debug) {
      console.log(`[vite-plugin-opal] Using bundler: ${this.useBundler}`)
      console.log(`[vite-plugin-opal] Working directory: ${process.cwd()}`)
      console.log(`[vite-plugin-opal] Include concerns: ${this.options.includeConcerns}`)
    }
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
    // Check cache
    const cached = this.cache.get(filePath)
    if (cached) {
      try {
        const stat = await fs.stat(filePath)
        if (stat.mtimeMs <= cached.mtime) {
          this.log(`Cache hit: ${filePath}`)
          return {
            code: cached.code,
            map: cached.map,
            dependencies: cached.dependencies
          }
        }
      } catch (e) {
        // File might have been deleted, remove from cache
        this.cache.delete(filePath)
      }
    }

    // Compile
    this.log(`Compiling: ${filePath}`)
    const result = await this.compileViaRuby(filePath)

    // Cache the result
    try {
      const stat = await fs.stat(filePath)
      this.cache.set(filePath, {
        ...result,
        mtime: stat.mtimeMs
      })
    } catch (e) {
      // Ignore if we can't stat the file
    }

    return result
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

  clearCache(filePath?: string): void {
    if (filePath) {
      this.cache.delete(filePath)
      this.log(`Cache cleared: ${filePath}`)
    } else {
      this.cache.clear()
      this.log('Cache cleared (all)')
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
        command = 'ruby'
        args = [
          '-I', this.resolveGemLibPath(),
          '-r', 'opal-vite',
          '-e', this.getCompilerScript(),
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
          reject(new Error(`Opal compilation failed:\n${stderr}`))
          return
        }

        try {
          const result = JSON.parse(stdout)
          resolve(result)
        } catch (e) {
          reject(new Error(`Failed to parse compiler output:\n${stdout}\n\nError: ${e}`))
        }
      })

      ruby.on('error', (err) => {
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
        command = 'ruby'
        args = [
          '-I', this.resolveGemLibPath(),
          '-r', 'opal-vite',
          '-e', 'puts Opal::Vite::Compiler.runtime_code'
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
    return `
      require 'opal-vite'
      file_path = ARGV[0]
      Opal::Vite.compile_for_vite(file_path, include_concerns: ${includeConcerns}, source_map: ${sourceMap})
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

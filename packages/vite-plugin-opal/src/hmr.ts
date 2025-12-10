import type { ViteDevServer, ModuleNode, Update } from 'vite'
import type { OpalCompiler } from './compiler'
import type { OpalResolver } from './resolver'
import type { OpalPluginOptions } from './types'
import * as path from 'path'
import * as chokidar from 'chokidar'

export interface HMRManager {
  setup(): void
  cleanup(): void
  handleFileChange(filePath: string): Promise<void>
}

export class OpalHMRManager implements HMRManager {
  private server: ViteDevServer
  private compiler: OpalCompiler
  private resolver: OpalResolver
  private options: OpalPluginOptions
  private watcher?: chokidar.FSWatcher
  private dependencyGraph: Map<string, Set<string>> = new Map()

  constructor(
    server: ViteDevServer,
    compiler: OpalCompiler,
    resolver: OpalResolver,
    options: OpalPluginOptions
  ) {
    this.server = server
    this.compiler = compiler
    this.resolver = resolver
    this.options = options
  }

  /**
   * Setup HMR file watching
   */
  setup(): void {
    this.log('Setting up HMR for .rb files')

    // Watch .rb files for changes
    this.watcher = chokidar.watch('**/*.rb', {
      ignored: /node_modules/,
      persistent: true,
      cwd: this.server.config.root,
      ignoreInitial: true // Don't trigger on initial scan
    })

    this.watcher.on('change', async (filePath: string) => {
      await this.handleFileChange(filePath)
    })

    this.watcher.on('add', async (filePath: string) => {
      this.log(`New file detected: ${filePath}`)
      await this.handleFileChange(filePath)
    })

    this.watcher.on('unlink', (filePath: string) => {
      this.log(`File removed: ${filePath}`)
      const absolutePath = path.resolve(this.server.config.root, filePath)
      this.compiler.clearCache(absolutePath)
      this.resolver.clearCache(absolutePath)
      this.dependencyGraph.delete(absolutePath)
    })

    // Cleanup on server close
    this.server.httpServer?.on('close', () => {
      this.cleanup()
    })

    this.log('HMR setup complete')
  }

  /**
   * Cleanup resources
   */
  cleanup(): void {
    if (this.watcher) {
      this.log('Cleaning up HMR watcher')
      this.watcher.close()
      this.watcher = undefined
    }
  }

  /**
   * Handle file change and trigger HMR update
   */
  async handleFileChange(filePath: string): Promise<void> {
    const absolutePath = path.resolve(this.server.config.root, filePath)

    this.log(`File changed: ${filePath}`)

    try {
      // Clear caches for the changed file
      this.compiler.clearCache(absolutePath)
      this.resolver.clearCache(absolutePath)

      // Get the module from the module graph
      const module = this.server.moduleGraph.getModuleById(absolutePath)

      if (!module) {
        this.log(`Module not found in graph: ${filePath}`, 'warn')
        return
      }

      // Collect all modules that need to be updated
      const modulesToUpdate = new Set<ModuleNode>([module])

      // Find dependent modules (modules that import this one)
      await this.collectDependentModules(module, modulesToUpdate)

      // Invalidate all affected modules
      for (const mod of modulesToUpdate) {
        this.server.moduleGraph.invalidateModule(mod)
        this.log(`Invalidated: ${mod.url}`)
      }

      // Build HMR updates
      const updates: Update[] = Array.from(modulesToUpdate).map(mod => ({
        type: 'js-update' as const,
        path: mod.url,
        acceptedPath: mod.url,
        timestamp: Date.now()
      }))

      // Send HMR update to browser
      this.server.ws.send({
        type: 'update',
        updates
      })

      this.log(`✓ HMR update sent for ${updates.length} module(s)`, 'success')
    } catch (error) {
      this.handleError(filePath, error)
    }
  }

  /**
   * Collect all modules that depend on the given module
   */
  private async collectDependentModules(
    module: ModuleNode,
    result: Set<ModuleNode>
  ): Promise<void> {
    // Get modules that import this module
    for (const importer of module.importers) {
      if (!result.has(importer)) {
        result.add(importer)
        // Recursively collect their dependents
        await this.collectDependentModules(importer, result)
      }
    }
  }

  /**
   * Handle compilation or HMR errors
   */
  private handleError(filePath: string, error: unknown): void {
    const errorMessage = error instanceof Error ? error.message : String(error)

    this.log(`Error processing ${filePath}: ${errorMessage}`, 'error')

    // Send error overlay to browser
    this.server.ws.send({
      type: 'error',
      err: {
        message: `Opal compilation failed for ${filePath}`,
        stack: error instanceof Error ? error.stack : undefined,
        id: filePath,
        frame: this.extractErrorFrame(errorMessage),
        plugin: 'vite-plugin-opal',
        loc: this.extractErrorLocation(errorMessage)
      }
    })
  }

  /**
   * Extract error frame from error message
   */
  private extractErrorFrame(errorMessage: string): string | undefined {
    // Try to extract relevant code frame from error
    const lines = errorMessage.split('\n')
    const relevantLines = lines.slice(0, 10).join('\n')
    return relevantLines || undefined
  }

  /**
   * Extract error location from error message
   */
  private extractErrorLocation(errorMessage: string): { file?: string; line?: number; column?: number } | undefined {
    // Try to parse location from Opal error messages
    // Example: "file.rb:10:5: error message"
    const match = errorMessage.match(/(.+):(\d+):(\d+)/)
    if (match) {
      return {
        file: match[1],
        line: parseInt(match[2], 10),
        column: parseInt(match[3], 10)
      }
    }
    return undefined
  }

  /**
   * Log HMR messages
   */
  private log(message: string, level: 'info' | 'warn' | 'error' | 'success' = 'info'): void {
    if (!this.options.debug && level === 'info') {
      return
    }

    const prefix = '[vite-plugin-opal:hmr]'
    const timestamp = new Date().toLocaleTimeString()

    const colors = {
      info: '\x1b[36m',    // Cyan
      warn: '\x1b[33m',    // Yellow
      error: '\x1b[31m',   // Red
      success: '\x1b[32m'  // Green
    }
    const reset = '\x1b[0m'

    const color = colors[level]
    const levelText = level.toUpperCase().padEnd(7)

    console.log(`${color}${prefix} ${timestamp} [${levelText}]${reset} ${message}`)
  }

  /**
   * Get dependency graph information (for debugging)
   */
  getDependencyGraph(): Map<string, Set<string>> {
    return new Map(this.dependencyGraph)
  }
}

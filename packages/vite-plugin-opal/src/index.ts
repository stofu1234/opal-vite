import type { Plugin, ViteDevServer } from 'vite'
import { OpalCompiler } from './compiler'
import { OpalResolver } from './resolver'
import { OpalHMRManager } from './hmr'
import type { OpalPluginOptions } from './types'
import * as path from 'path'

const VIRTUAL_RUNTIME_ID = '/@opal-runtime'
const VIRTUAL_RUNTIME_PREFIX = '\0' + VIRTUAL_RUNTIME_ID

/**
 * Vite plugin for compiling Ruby files to JavaScript using Opal.
 *
 * @param options - Plugin configuration options
 * @returns Vite plugin instance
 *
 * @example
 * ```ts
 * import { defineConfig } from 'vite'
 * import opal from 'vite-plugin-opal'
 *
 * export default defineConfig({
 *   plugins: [
 *     opal({
 *       loadPaths: ['./app/opal'],
 *       sourceMap: true
 *     })
 *   ]
 * })
 * ```
 *
 * @example CDN mode
 * ```ts
 * import { defineConfig } from 'vite'
 * import opal from 'vite-plugin-opal'
 *
 * export default defineConfig({
 *   plugins: [
 *     opal({
 *       cdn: 'jsdelivr', // or 'unpkg', 'cdnjs', or custom URL
 *       opalVersion: '1.8.2'
 *     })
 *   ]
 * })
 * ```
 *
 * @see {@link OpalPluginOptions} for all available options
 */
export default function opalPlugin(options: OpalPluginOptions = {}): Plugin {
  const compiler = new OpalCompiler(options)
  const resolver = new OpalResolver(options)
  let server: ViteDevServer | undefined
  let hmrManager: OpalHMRManager | undefined
  let isBuild = false
  const useCdn = compiler.isCdnEnabled()
  const cdnUrl = compiler.getCdnUrl()

  return {
    name: 'vite-plugin-opal',
    enforce: 'pre', // Run before other plugins

    // Detect build vs serve mode
    config(_config, { command }) {
      isBuild = command === 'build'
    },

    // Mark .rb files as valid imports
    async resolveId(id: string, importer?: string) {
      // Handle virtual runtime module
      if (id === VIRTUAL_RUNTIME_ID) {
        if (options.debug) {
          console.log(`[vite-plugin-opal] Resolved virtual runtime: ${VIRTUAL_RUNTIME_PREFIX}`)
        }
        return VIRTUAL_RUNTIME_PREFIX
      }

      // Handle .rb files and files without extension (Opal style requires)
      if (id.endsWith('.rb') || (!id.includes('.') && !id.startsWith('/'))) {
        const resolved = await resolver.resolve(id, importer)
        if (options.debug) {
          console.log(`[vite-plugin-opal] resolveId: ${id} -> ${resolved}`)
        }
        return resolved
      }

      return null
    },

    // Load and compile .rb files
    async load(id: string) {
      // Handle virtual runtime module
      if (id === VIRTUAL_RUNTIME_PREFIX) {
        // In CDN mode, return a small stub that expects Opal to be globally available
        if (useCdn) {
          if (options.debug) {
            console.log(`[vite-plugin-opal] Using CDN for Opal runtime: ${cdnUrl}`)
          }
          return {
            code: `// Opal runtime loaded from CDN: ${cdnUrl}\n// The runtime is loaded via script tag in index.html\nif (typeof Opal === 'undefined') {\n  console.error('[vite-plugin-opal] Opal runtime not found. Make sure the CDN script is loaded before your application code.');\n}\n`,
            map: null
          }
        }

        if (options.debug) {
          console.log(`[vite-plugin-opal] Loading Opal runtime...`)
        }
        const runtime = await compiler.getOpalRuntime()
        if (options.debug) {
          console.log(`[vite-plugin-opal] Opal runtime loaded: ${runtime.length} bytes`)
        }
        return {
          code: runtime,
          map: null
        }
      }

      // Handle .rb files
      if (id.endsWith('.rb')) {
        if (options.debug) {
          console.log(`[vite-plugin-opal] load: Compiling ${id}`)
        }
        try {
          const result = await compiler.compile(id)
          if (options.debug) {
            console.log(`[vite-plugin-opal] load: Compiled ${id} -> ${result.code.length} bytes`)
            console.log(`[vite-plugin-opal] load: Source map: ${result.map ? 'yes' : 'no'}`)
          }
          const sourceMap = result.map ? JSON.parse(result.map) : null
          if (options.debug && sourceMap) {
            console.log(`[vite-plugin-opal] load: Source map version: ${sourceMap.version}, sections: ${sourceMap.sections?.length || 0}`)
          }
          return {
            code: result.code,
            map: sourceMap
          }
        } catch (error) {
          console.error(`[vite-plugin-opal] Compilation error for ${id}:`, error)
          this.error(error instanceof Error ? error.message : String(error))
        }
      }

      return null
    },

    // Auto-inject Opal runtime into HTML
    transformIndexHtml(html: string) {
      let runtimeScript: string

      if (useCdn && cdnUrl) {
        // CDN mode: inject script tag that loads Opal from CDN
        // This works for both development and production builds
        runtimeScript = `<script src="${cdnUrl}"></script>`
        if (options.debug) {
          console.log(`[vite-plugin-opal] Injecting CDN script: ${cdnUrl}`)
        }
      } else {
        // Local mode: skip injection during build - runtime is bundled into JS
        if (isBuild) {
          return html
        }
        // Inject runtime module reference (development only)
        runtimeScript = `<script type="module" src="${VIRTUAL_RUNTIME_ID}"></script>`
      }

      if (html.includes('</head>')) {
        return html.replace('</head>', `  ${runtimeScript}\n</head>`)
      } else if (html.includes('<head>')) {
        return html.replace('<head>', `<head>\n  ${runtimeScript}`)
      } else {
        // No head tag, inject at the beginning
        return `${runtimeScript}\n${html}`
      }
    },

    // Setup HMR for .rb files
    configureServer(_server: ViteDevServer) {
      server = _server

      // Initialize HMR manager
      hmrManager = new OpalHMRManager(server, compiler, resolver, options)
      hmrManager.setup()

      return () => {
        // Cleanup function called when server closes
        if (hmrManager) {
          hmrManager.cleanup()
        }
      }
    }
  }
}

export type { OpalPluginOptions } from './types'

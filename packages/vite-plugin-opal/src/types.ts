/**
 * Configuration options for the Opal Vite plugin
 *
 * @example
 * ```ts
 * import { defineConfig } from 'vite'
 * import opal from 'vite-plugin-opal'
 *
 * export default defineConfig({
 *   plugins: [
 *     opal({
 *       loadPaths: ['./app/opal', './lib/opal'],
 *       sourceMap: true,
 *       debug: false
 *     })
 *   ]
 * })
 * ```
 */
export interface OpalPluginOptions {
  /**
   * Path to the opal-vite gem directory.
   * If not specified, the gem will be loaded from the default gem path.
   *
   * @default 'opal-vite'
   * @example
   * ```ts
   * {
   *   gemPath: '/path/to/custom/opal-vite'
   * }
   * ```
   */
  gemPath?: string

  /**
   * Enable source map generation for debugging Ruby code in browser DevTools.
   * When enabled, you can set breakpoints and step through your Ruby code.
   *
   * @default true
   * @example
   * ```ts
   * {
   *   sourceMap: true // Enable for development
   * }
   * ```
   */
  sourceMap?: boolean

  /**
   * Additional load paths for Ruby `require` statements.
   * Files in these directories can be required without specifying the full path.
   *
   * @default ['./src']
   * @example
   * ```ts
   * {
   *   loadPaths: [
   *     './app/opal',        // Application code
   *     './lib/opal',        // Libraries
   *     './app/controllers'  // Controllers
   *   ]
   * }
   * ```
   */
  loadPaths?: string[]

  /**
   * Enable runtime arity checking for method calls.
   * When enabled, Opal will check that methods are called with the correct number of arguments.
   * Useful for development, but adds runtime overhead.
   *
   * @default false
   * @example
   * ```ts
   * {
   *   arityCheck: true // Enable for development
   * }
   * ```
   */
  arityCheck?: boolean

  /**
   * Enable object freezing to prevent modification of frozen objects.
   * This matches Ruby's Object#freeze behavior more closely.
   *
   * @default true
   * @example
   * ```ts
   * {
   *   freezing: true // Enable for Ruby compliance
   * }
   * ```
   */
  freezing?: boolean

  /**
   * Enable debug logging to console.
   * Logs compilation steps, file resolutions, and HMR updates.
   * Useful for troubleshooting compilation issues.
   *
   * @default false
   * @example
   * ```ts
   * {
   *   debug: true // Enable to see plugin activity
   * }
   * ```
   */
  debug?: boolean

  /**
   * Use `bundle exec` to run Ruby commands.
   * Automatically detects presence of Gemfile if not specified.
   * Set to `false` to disable bundler even when Gemfile exists.
   *
   * @default auto-detect (true if Gemfile exists in project root)
   * @example
   * ```ts
   * {
   *   useBundler: true // Force bundler usage
   * }
   * ```
   */
  useBundler?: boolean

  /**
   * Include built-in concerns (JsProxyEx, DomHelpers, Toastable, Storable).
   * When enabled, these modules are automatically available via:
   * - `require 'opal_vite/concerns/js_proxy_ex'`
   * - `require 'opal_vite/concerns/dom_helpers'`
   * - `require 'opal_vite/concerns/toastable'`
   * - `require 'opal_vite/concerns/storable'`
   *
   * @default true
   * @example
   * ```ts
   * {
   *   includeConcerns: true // Enable built-in concerns
   * }
   * ```
   */
  includeConcerns?: boolean

  // ============================================
  // Performance Optimization Options (v0.3.2+)
  // ============================================

  /**
   * Enable disk-based caching for compiled files.
   * Persists cache across dev server restarts for faster rebuilds.
   * Cache is stored in node_modules/.cache/opal-vite/
   *
   * @default true
   * @example
   * ```ts
   * {
   *   diskCache: true // Enable persistent caching
   * }
   * ```
   */
  diskCache?: boolean

  /**
   * Custom directory for disk cache.
   * If not specified, uses node_modules/.cache/opal-vite/
   *
   * @default undefined (auto-detect)
   * @example
   * ```ts
   * {
   *   cacheDir: '.cache/opal'
   * }
   * ```
   */
  cacheDir?: string

  /**
   * Modules to stub (replace with empty implementations).
   * Useful for excluding server-side only gems or large unused libraries.
   * Reduces bundle size by replacing modules with empty exports.
   *
   * @default []
   * @example
   * ```ts
   * {
   *   stubs: ['active_support', 'sprockets', 'listen']
   * }
   * ```
   */
  stubs?: string[]

  /**
   * Maximum number of concurrent Ruby processes for compilation.
   * Higher values can speed up initial builds with many files.
   * Set to 1 to disable parallel compilation.
   *
   * @default 4
   * @example
   * ```ts
   * {
   *   parallelCompilation: 8 // Allow 8 concurrent compilations
   * }
   * ```
   */
  parallelCompilation?: number

  /**
   * Enable compilation metrics logging.
   * Logs timing information for each compilation step.
   * Useful for identifying performance bottlenecks.
   *
   * @default false
   * @example
   * ```ts
   * {
   *   metrics: true // Enable performance metrics
   * }
   * ```
   */
  metrics?: boolean

  // ============================================
  // CDN Options (v0.3.5+)
  // ============================================

  /**
   * Load Opal runtime from CDN instead of bundling it.
   * This reduces bundle size and improves caching across sites.
   *
   * Supported values:
   * - `false` or `undefined`: Bundle runtime locally (default)
   * - `'unpkg'`: Use unpkg CDN (https://unpkg.com)
   * - `'jsdelivr'`: Use jsDelivr CDN (https://cdn.jsdelivr.net)
   * - `'cdnjs'`: Use cdnjs CDN (https://cdnjs.cloudflare.com)
   * - Custom URL string: Use a custom CDN URL (must end with opal.min.js or opal.js)
   *
   * @default false
   * @example
   * ```ts
   * // Use jsDelivr CDN
   * {
   *   cdn: 'jsdelivr'
   * }
   *
   * // Use custom CDN URL
   * {
   *   cdn: 'https://my-cdn.example.com/opal/1.8.2/opal.min.js'
   * }
   * ```
   */
  cdn?: 'unpkg' | 'jsdelivr' | 'cdnjs' | string | false

  /**
   * Opal version to use when loading from CDN.
   * Only used when `cdn` is set to a CDN provider name.
   *
   * @default '1.8.2'
   * @example
   * ```ts
   * {
   *   cdn: 'jsdelivr',
   *   opalVersion: '1.8.2'
   * }
   * ```
   */
  opalVersion?: string
}

/**
 * Result of compiling a Ruby file to JavaScript
 */
export interface CompileResult {
  /**
   * Compiled JavaScript code
   */
  code: string

  /**
   * Source map as JSON string (if sourceMap is enabled)
   */
  map?: string

  /**
   * List of file dependencies (other Ruby files required by this file)
   */
  dependencies?: string[]

  /**
   * Compilation timestamp
   */
  timestamp?: number
}

/**
 * Cache entry for compiled files
 * @internal
 */
export interface CacheEntry extends CompileResult {
  /**
   * File modification time (used for cache invalidation)
   */
  mtime: number
}

/**
 * Structured error information from Opal compilation failures
 */
export interface OpalCompilationError {
  /**
   * Human-readable error message
   */
  message: string

  /**
   * Source file where the error occurred
   */
  file?: string

  /**
   * Line number in the source file (1-based)
   */
  line?: number

  /**
   * Column number in the source file (1-based)
   */
  column?: number

  /**
   * Type of error (SyntaxError, NameError, LoadError, etc.)
   */
  errorType?: string

  /**
   * Helpful hint for resolving the error
   */
  hint?: string

  /**
   * Raw error output from Ruby for debugging
   */
  rawOutput?: string
}

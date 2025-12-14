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

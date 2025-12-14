export interface OpalPluginOptions {
  /**
   * Path to the opal-vite gem
   * @default 'opal-vite'
   */
  gemPath?: string

  /**
   * Enable source map generation
   * @default true
   */
  sourceMap?: boolean

  /**
   * Load paths for Ruby requires
   * @default ['./src']
   */
  loadPaths?: string[]

  /**
   * Enable arity checking
   * @default false
   */
  arityCheck?: boolean

  /**
   * Enable object freezing
   * @default true
   */
  freezing?: boolean

  /**
   * Enable debug logging
   * @default false
   */
  debug?: boolean

  /**
   * Use bundle exec to run Ruby
   * @default auto-detect (true if Gemfile exists)
   */
  useBundler?: boolean
}

export interface CompileResult {
  code: string
  map?: string
  dependencies?: string[]
  timestamp?: number
}

export interface CacheEntry extends CompileResult {
  mtime: number
}

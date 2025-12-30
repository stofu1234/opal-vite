# Production Build Optimization

This guide covers best practices for optimizing your Opal + Vite application for production deployment.

## Default Minification

Vite uses [esbuild](https://esbuild.github.io/) by default for minification, which provides:

- Fast build times
- Variable name minification
- Dead code elimination
- Whitespace removal

This is sufficient for most applications.

## Enhanced Minification with Terser

For better compression (5-6% smaller output), you can use [Terser](https://terser.org/) instead:

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [opal()],
  build: {
    minify: 'terser',
    terserOptions: {
      compress: {
        passes: 2
      },
      mangle: true,
      format: {
        comments: false
      }
    }
  }
})
```

### Size Comparison

| Minifier | Raw Size | Gzip Size |
|----------|----------|-----------|
| esbuild (default) | 374 KB | 104 KB |
| Terser | 359 KB | 98 KB |

::: tip
Install Terser as a dev dependency:
```bash
pnpm add -D terser
```
:::

## Source Maps in Production

For production builds, consider disabling source maps to reduce bundle size and hide source code:

```typescript
// vite.config.ts
export default defineConfig({
  plugins: [
    opal({
      sourceMap: false  // Disable Opal source maps
    })
  ],
  build: {
    sourcemap: false    // Disable Vite source maps
  }
})
```

## Understanding Opal's Output

### What Gets Minified

- **Variable names**: Shortened to single characters (`e`, `k`, `H`, etc.)
- **Comments**: Removed entirely
- **Whitespace**: Removed

### What Remains Readable

Due to Ruby's metaprogramming features (`method_missing`, `respond_to?`, `send`), the following remain as string identifiers:

- **Ruby class names**: `$Array`, `$String`, `$Hash`, etc.
- **Ruby method names**: `.$to_s`, `.$inspect`, `.$each`, etc.

This is by design and cannot be changed without breaking Ruby compatibility.

### Comparison with Other SPAs

| Feature | React/Vue | Opal |
|---------|-----------|------|
| Variable names | Minified | Minified |
| Function names | Minified | Preserved (strings) |
| Class names | Minified | Preserved (strings) |

## Recommended Production Configuration

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      sourceMap: false,      // No source maps in production
      debug: false           // No debug output
    })
  ],
  build: {
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,  // Remove console.log
        passes: 2
      },
      mangle: true,
      format: {
        comments: false
      }
    },
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: {
          // Split Opal runtime into separate chunk for better caching
          'opal-runtime': ['/@opal-runtime']
        }
      }
    }
  }
})
```

## Security Considerations

::: warning
JavaScript in the browser is always accessible to users. For truly sensitive logic:

1. **Move to server-side**: Keep business logic in your backend API
2. **Use authentication**: Protect sensitive endpoints
3. **Validate server-side**: Never trust client-side validation alone
:::

Minification and obfuscation are deterrents, not security measures. They increase the effort required to understand your code but cannot prevent determined reverse engineering.

## Performance Optimizations (v0.3.2+)

### Disk Cache

Enable persistent disk caching to speed up dev server restarts and rebuilds:

```typescript
// vite.config.ts
export default defineConfig({
  plugins: [
    opal({
      diskCache: true,           // Enable disk cache (default: true)
      cacheDir: '.cache/opal'    // Custom cache directory (optional)
    })
  ]
})
```

Cache is stored in `node_modules/.cache/opal-vite/` by default. Files are cached based on content hash, so unchanged files are served instantly.

### Parallel Compilation

Speed up initial builds by compiling multiple Ruby files simultaneously:

```typescript
// vite.config.ts
export default defineConfig({
  plugins: [
    opal({
      parallelCompilation: 8  // Allow 8 concurrent compilations (default: 4)
    })
  ]
})
```

::: tip
Higher values can speed up initial builds but may increase memory usage. Adjust based on your system's capabilities.
:::

### Module Stubs

Exclude server-side only gems or large unused libraries to reduce bundle size:

```typescript
// vite.config.ts
export default defineConfig({
  plugins: [
    opal({
      stubs: [
        'active_support',   // Exclude Active Support
        'sprockets',        // Exclude Sprockets
        'listen',           // Exclude file watching gems
        'logger'            // Exclude logging gems
      ]
    })
  ]
})
```

Stubbed modules are replaced with empty implementations that simply mark themselves as loaded.

### Compilation Metrics

Enable metrics to analyze compilation performance:

```typescript
// vite.config.ts
export default defineConfig({
  plugins: [
    opal({
      metrics: true   // Enable performance metrics
    })
  ]
})
```

Metrics output shows:
- Total files compiled
- Cache hit rate (memory vs disk)
- Average compilation duration
- Per-file timing details (with `debug: true`)

## Performance Tips

### 1. Code Splitting

Split your application into smaller chunks:

```typescript
// Lazy load routes or features
const AdminPanel = await import('./admin_panel.rb')
```

### 2. Tree Shaking

Only import what you need:

```ruby
# Good - specific import
require 'opal_vite/concerns/storable'

# Avoid - imports everything
require 'opal_vite'
```

### 3. Preload Critical Assets

```html
<link rel="modulepreload" href="/assets/opal-runtime.js">
```

## Environment-Specific Configuration

Use Vite's environment modes:

```typescript
// vite.config.ts
export default defineConfig(({ mode }) => ({
  plugins: [
    opal({
      sourceMap: mode === 'development',
      debug: mode === 'development'
    })
  ],
  build: {
    minify: mode === 'production' ? 'terser' : false,
    sourcemap: mode === 'development'
  }
}))
```

## Related

- [Source Maps](./source-maps.md)
- [Troubleshooting](./troubleshooting.md)

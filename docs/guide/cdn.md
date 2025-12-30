# CDN Support

opal-vite v0.3.5+ supports loading the Opal runtime from CDN, which can significantly reduce bundle size and improve caching.

## Benefits

- **Reduced bundle size**: Opal runtime (~200KB minified) is loaded from CDN instead of being bundled
- **Better caching**: CDN files are cached across multiple sites
- **Faster initial loads**: Users who visited other Opal-powered sites may already have the runtime cached

## Configuration

### Using a CDN Provider

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      cdn: 'jsdelivr',  // or 'unpkg', 'cdnjs'
      opalVersion: '1.8.2'
    })
  ]
})
```

### Supported CDN Providers

| Provider | Option Value | URL Pattern |
|----------|-------------|-------------|
| jsDelivr | `'jsdelivr'` | `https://cdn.jsdelivr.net/npm/opal-runtime@{version}/dist/opal.min.js` |
| unpkg | `'unpkg'` | `https://unpkg.com/opal-runtime@{version}/dist/opal.min.js` |
| cdnjs | `'cdnjs'` | `https://cdnjs.cloudflare.com/ajax/libs/opal/{version}/opal.min.js` |

### Using a Custom CDN URL

You can also specify a custom CDN URL:

```typescript
opal({
  cdn: 'https://my-cdn.example.com/opal/1.8.2/opal.min.js'
})
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `cdn` | `'unpkg' \| 'jsdelivr' \| 'cdnjs' \| string \| false` | `false` | CDN provider or custom URL |
| `opalVersion` | `string` | `'1.8.2'` | Opal version to load from CDN |

## How It Works

When CDN mode is enabled:

1. **HTML Injection**: A `<script>` tag pointing to the CDN is automatically injected into your HTML
2. **Runtime Stub**: The virtual `/@opal-runtime` module returns a stub that verifies Opal is loaded
3. **Both Modes**: Works in both development and production builds

### Generated HTML

```html
<!-- CDN mode -->
<head>
  <script src="https://cdn.jsdelivr.net/npm/opal-runtime@1.8.2/dist/opal.min.js"></script>
</head>

<!-- Local mode (default) -->
<head>
  <script type="module" src="/@opal-runtime"></script>
</head>
```

## When to Use CDN Mode

### Recommended for:

- Production deployments
- Sites with multiple Opal-powered pages
- When bundle size is a concern

### Not recommended for:

- Development (local runtime provides better debugging)
- Offline applications
- Environments with restricted network access

## Example: Production Configuration

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      // Use CDN in production, local in development
      cdn: process.env.NODE_ENV === 'production' ? 'jsdelivr' : false,
      opalVersion: '1.8.2',
      sourceMap: process.env.NODE_ENV !== 'production'
    })
  ]
})
```

## Troubleshooting

### "Opal runtime not found" Error

If you see this error in the console, the CDN script hasn't loaded properly. Check:

1. Network connectivity to the CDN
2. CDN URL is correct
3. Script tag is in the HTML `<head>` before your application code

### Version Mismatch

Ensure the `opalVersion` matches the Opal gem version in your project:

```bash
# Check gem version
bundle show opal

# Update vite.config.ts to match
opal({
  cdn: 'jsdelivr',
  opalVersion: '1.8.2'  // Match your gem version
})
```

## Related

- [Installation Guide](/guide/installation) - Basic setup
- [Production Build](/guide/production-build) - Build optimization

# Source Maps in opal-vite

Source maps allow you to debug your Ruby code directly in browser DevTools, even though it's compiled to JavaScript.

## Overview

When source maps are enabled (default), opal-vite generates Source Map v3 compatible mappings that:

1. **Map JavaScript back to Ruby** - Click on errors in DevTools to see the original Ruby line
2. **Include original source** - The Ruby source code is embedded in the source map
3. **Support browser debugging** - Set breakpoints in your Ruby files

## Configuration

### Vite Plugin Options

```typescript
import { defineConfig } from 'vite'
import opal from 'vite-plugin-opal'

export default defineConfig({
  plugins: [
    opal({
      sourceMap: true  // Enabled by default
    })
  ],
  build: {
    sourcemap: true  // Also enable for production builds
  }
})
```

### Ruby Configuration

```ruby
# Configure via Opal::Vite
Opal::Vite.configure do |config|
  config.source_map_enabled = true  # Enabled by default
end
```

## How It Works

1. **Compilation**: When Opal compiles Ruby to JavaScript, it generates source map data
2. **Index Format**: Multiple files are combined into an index source map with sections
3. **Vite Integration**: The source map is passed to Vite which handles the browser delivery
4. **Browser Display**: DevTools shows Ruby files in the Sources panel

## Debugging in Browser

1. Open DevTools (F12)
2. Go to the **Sources** tab
3. Find your Ruby files under the source tree
4. Set breakpoints by clicking line numbers
5. Variable values are shown (though with JavaScript names)

## Source Map Structure

The generated source maps follow the v3 specification:

```json
{
  "version": 3,
  "sections": [
    {
      "offset": { "line": 0, "column": 0 },
      "map": {
        "version": 3,
        "sources": ["app/opal/controllers/my_controller.rb"],
        "sourcesContent": ["# Original Ruby code..."],
        "names": ["method_name", "variable"],
        "mappings": "AAAA..."
      }
    }
  ]
}
```

## Disabling Source Maps

For production builds where you don't want source maps:

```typescript
// vite.config.ts
export default defineConfig({
  plugins: [
    opal({
      sourceMap: false
    })
  ],
  build: {
    sourcemap: false
  }
})
```

## Troubleshooting

### Source maps not appearing in DevTools

1. Ensure `sourceMap: true` in plugin options
2. Check Vite's `build.sourcemap` setting
3. Verify DevTools has "Enable JavaScript source maps" checked

### Incorrect line mappings

Opal's source maps map at the expression level, not character-by-character. Some complex Ruby expressions may map to approximate JavaScript locations.

### Large source map files

Source maps include original source content. For production, consider:
- Setting `build.sourcemap: 'hidden'` to generate but not reference
- Using source maps only in development

## Performance

Source map generation adds minimal overhead to compilation (~5-10%). The maps are only generated once per file and cached by Vite.

## Related Documentation

- [Opal Source Maps Guide](https://opalrb.com/docs/guides/v1.4.1/source_maps.html)
- [Vite Source Maps Configuration](https://vitejs.dev/config/build-options.html#build-sourcemap)
- [Source Map v3 Specification](https://sourcemaps.info/spec.html)

# Opal Vite VS Code Extension

VS Code extension for Opal (Ruby to JavaScript) development with Vite.

## Features

### Syntax Highlighting

- Full Ruby/Opal syntax highlighting
- Special highlighting for Opal-specific constructs:
  - Native JavaScript blocks (`` `...` ``)
  - `Native`, `JS::Object`, `PromiseV2`
  - OpalVite::Concerns modules

### Opal Incompatible Syntax Warnings

Automatically detects and warns about Ruby code that won't work in Opal:

- **Threading**: `Thread`, `Mutex`, `Queue` (JavaScript is single-threaded)
- **File System**: `File`, `Dir`, `IO` operations (not available in browser)
- **Process**: `system`, `exec`, `fork`, `spawn`
- **Sockets**: `TCPSocket`, `UDPSocket`, etc.
- **Native Extensions**: gems like `nokogiri`, `mysql2`, `pg`

### Code Snippets

Quickly scaffold common Opal patterns:

| Prefix | Description |
|--------|-------------|
| `opal-controller` | Stimulus controller |
| `opal-controller-concerns` | Stimulus controller with OpalVite concerns |
| `opal-service` | Service class with concerns |
| `opal-presenter` | Presenter class pattern |
| `native-js` | Native JavaScript block |
| `promise` | PromiseV2 creation |
| `fetch` | Fetch API call |

#### OpalVite::Concerns Snippets

| Prefix | Description |
|--------|-------------|
| `dom-helpers` | Include DomHelpers |
| `storable` | Include Storable (localStorage/sessionStorage) |
| `toastable` | Include Toastable (toast notifications) |
| `base64-helpers` | Include Base64Helpers |
| `uri-helpers` | Include URIHelpers |

#### DOM Helper Snippets

| Prefix | Description |
|--------|-------------|
| `query-selector` | Query DOM element |
| `query-selector-all` | Query all DOM elements |
| `element-by-id` | Get element by ID |
| `create-element` | Create new element |
| `add-event-listener` | Add event listener |

#### Storage Snippets

| Prefix | Description |
|--------|-------------|
| `ls-get` | localStorage get |
| `ls-set` | localStorage set |
| `ss-get` | sessionStorage get |
| `ss-set` | sessionStorage set |

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `opalVite.enableDiagnostics` | `true` | Enable Opal incompatible syntax diagnostics |
| `opalVite.diagnosticSeverity` | `warning` | Severity level for warnings |
| `opalVite.autoDetectOpalFiles` | `true` | Auto-detect Opal files in `app/opal` directory |

## Commands

- **Opal Vite: Toggle Diagnostics** - Enable/disable incompatible syntax warnings
- **Opal Vite: Compile Current File** - Compile current Opal file using `opal` CLI

## File Detection

The extension automatically activates for:
- Files in `app/opal/` directory
- Files containing Opal-specific patterns (`` `...` ``, `Native`, `OpalVite::`)
- Files with `.opal` extension

## Requirements

- VS Code 1.85.0 or higher
- For compilation: Ruby and Opal gem installed

## Installation

### From VS Code Marketplace

Search for "Opal Vite" in the VS Code Extensions panel.

### Manual Installation

```bash
cd packages/vscode-opal-vite
npm install
npm run compile
npm run package
code --install-extension vscode-opal-vite-0.3.2.vsix
```

## Development

```bash
# Install dependencies
npm install

# Compile TypeScript
npm run compile

# Watch for changes
npm run watch

# Package extension
npm run package
```

## License

MIT

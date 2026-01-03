# Opal-Vite IntelliJ Plugin

IntelliJ IDEA plugin for enhanced Ruby/Opal development with opal-vite projects.

## Features

- **LSP Integration**: Connects to [opal-language-server](../opal-language-server) for intelligent code assistance
- **Diagnostics**: Warnings for Opal-incompatible Ruby patterns (Thread, File, IO, etc.)
- **Live Templates**: 40+ code snippets for Stimulus controllers, OpalVite concerns, and more
- **Settings UI**: Configurable diagnostics severity and server options

## Requirements

- **IntelliJ IDEA Ultimate 2024.1 or later** (Ruby plugin requires Ultimate edition)
- [Ruby plugin](https://plugins.jetbrains.com/plugin/1293-ruby) installed
- [LSP4IJ plugin](https://plugins.jetbrains.com/plugin/23257-lsp4ij) installed
- Node.js (for opal-language-server)

> **Note**: RubyMine is also supported as it includes Ruby plugin by default.

## Installation

### From JetBrains Marketplace (Recommended)

1. Open IntelliJ IDEA
2. Go to **Settings** → **Plugins** → **Marketplace**
3. Search for "Opal-Vite"
4. Click **Install**

### Manual Installation

1. Download the latest release from [GitHub Releases](https://github.com/stofu1234/opal-vite/releases)
2. Go to **Settings** → **Plugins** → **⚙️** → **Install Plugin from Disk...**
3. Select the downloaded `.zip` file

## Setup

### 1. Install opal-language-server

```bash
npm install -g opal-language-server
```

Or add to your project:

```bash
npm install --save-dev opal-language-server
```

### 2. Configure Settings (Optional)

Go to **Settings** → **Tools** → **Opal-Vite** to configure:

- **Server path**: Custom path to opal-language-server (leave empty for auto-detection)
- **Enable diagnostics**: Toggle Opal-incompatible pattern warnings
- **Severity level**: error / warning / information / hint
- **Auto-detect Opal files**: Enable for files in `app/opal/` directories

## Live Templates

Type the abbreviation and press `Tab` to expand:

### Controllers
| Abbreviation | Description |
|--------------|-------------|
| `opal-controller` | Create Stimulus controller |
| `opal-controller-concerns` | Create controller with OpalVite concerns |
| `opal-service` | Create service class |
| `opal-presenter` | Create presenter class |

### OpalVite Concerns
| Abbreviation | Description |
|--------------|-------------|
| `include-dom` | Include DomHelpers |
| `include-stimulus` | Include StimulusHelpers |
| `include-storable` | Include Storable |
| `include-toastable` | Include Toastable |
| `include-jsproxy` | Include JsProxyEx |
| `include-uri` | Include URIHelpers |
| `include-base64` | Include Base64Helpers |
| `include-debug` | Include DebugHelpers |
| `include-actioncable` | Include ActionCableHelpers |
| `include-turbo` | Include TurboHelpers |

### DOM & Storage
| Abbreviation | Description |
|--------------|-------------|
| `query-selector` | Query DOM element |
| `query-selector-all` | Query all elements |
| `element-by-id` | Get element by ID |
| `create-element` | Create DOM element |
| `add-event-listener` | Add event listener |
| `ls-get` / `ls-set` | localStorage operations |
| `ss-get` / `ss-set` | sessionStorage operations |

### Async & Native JS
| Abbreviation | Description |
|--------------|-------------|
| `native-js` | Inline JavaScript |
| `native-js-multi` | Multiline JavaScript |
| `promise` | Create PromiseV2 |
| `promise-then` | Add then handler |
| `promise-fail` | Add fail handler |
| `fetch` | Fetch API call |

### Stimulus Definitions
| Abbreviation | Description |
|--------------|-------------|
| `targets` | Define targets |
| `values` | Define values |
| `classes` | Define classes |
| `action` | Define action method |

## Diagnostics

The plugin warns about Ruby patterns that are not compatible with Opal:

- **Threading**: `Thread.new`, `Mutex`, `Queue`, `ConditionVariable`
- **File System**: `File.read`, `File.write`, `Dir.glob`, `IO.read`
- **Networking**: `TCPSocket`, `UDPSocket`, `HTTP.get`
- **Native Extensions**: `nokogiri`, `mysql2`, `pg`, `sqlite3`
- **Process Control**: `fork`, `exec`, `system` (shell commands)

## Development

### Building

```bash
cd packages/intellij-opal-vite
./gradlew build
```

### Running in Development

```bash
./gradlew runIde
```

### Creating Distribution

```bash
./gradlew buildPlugin
```

The plugin ZIP will be created in `build/distributions/`.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    opal-language-server                      │
│  (Shared: patterns, snippets, diagnostics logic)            │
└─────────────────────────────────────────────────────────────┘
        ▲                    ▲                    ▲
        │ LSP               │ LSP               │ API
        │                    │                    │
┌───────┴───────┐   ┌───────┴───────┐   ┌───────┴───────┐
│  VS Code      │   │  IntelliJ     │   │  Vim/Neovim   │
│  Extension    │   │  Plugin       │   │  (future)     │
└───────────────┘   └───────────────┘   └───────────────┘
```

## License

MIT License - see [LICENSE](../../LICENSE) for details.

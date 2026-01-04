# vim-opal-vite

Vim/Neovim plugin for Opal development with Vite. Provides LSP integration, diagnostics, and code snippets for Opal (Ruby to JavaScript) projects.

## Features

- **LSP Integration**: Full Language Server Protocol support via `opal-language-server`
- **Diagnostics**: Warnings for Opal-incompatible Ruby patterns
  - Threading (Thread, Mutex, Queue)
  - File system operations (File, Dir, IO)
  - Socket operations (TCPSocket, etc.)
  - Native C extensions (nokogiri, mysql2, pg)
- **Code Snippets**: 40+ snippets for Stimulus controllers, services, and OpalVite concerns
- **Auto-detection**: Automatically identifies Opal files in `app/opal/` directories

## Requirements

### Neovim (Recommended)

- Neovim 0.8.0+
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- Node.js 18+ (for running the language server)
- Optional: [LuaSnip](https://github.com/L3MON4D3/LuaSnip) or [UltiSnips](https://github.com/SirVer/ultisnips)

### Vim

- Vim 8.0+
- UltiSnips for snippets (no LSP support)

## Installation

### Using lazy.nvim

```lua
{
  "stofu1234/opal-vite",
  config = function()
    require("opal_vite").setup({
      enable_diagnostics = true,
      diagnostic_severity = "warn",
    })
  end,
  dependencies = {
    "neovim/nvim-lspconfig",
  },
}
```

### Using packer.nvim

```lua
use {
  "stofu1234/opal-vite",
  requires = { "neovim/nvim-lspconfig" },
  config = function()
    require("opal_vite").setup()
  end,
}
```

### Using vim-plug

```vim
Plug 'neovim/nvim-lspconfig'
Plug 'stofu1234/opal-vite', { 'rtp': 'packages/vim-opal-vite' }
```

### Manual Installation

1. Clone the repository
2. Add `packages/vim-opal-vite` to your runtimepath
3. Install the language server: `npm install -g opal-language-server`

## Configuration

### Neovim (Lua)

```lua
require("opal_vite").setup({
  -- Enable LSP diagnostics (default: true)
  enable_diagnostics = true,

  -- Diagnostic severity: "error", "warn", "info", "hint"
  diagnostic_severity = "warn",

  -- Auto-detect Opal files in app/opal/ directories (default: true)
  auto_detect_opal_files = true,

  -- Custom path to opal-language-server (default: use npx)
  server_cmd = nil,

  -- Additional LSP settings
  lsp_settings = {},
})
```

### Vim

```vim
" Enable/disable diagnostics
let g:opal_vite_enable_diagnostics = 1

" Diagnostic severity
let g:opal_vite_diagnostic_severity = 'warn'

" Auto-detect Opal files
let g:opal_vite_auto_detect = 1
```

## Commands

| Command | Description |
|---------|-------------|
| `:OpalRestart` | Restart the Opal Language Server |
| `:OpalInfo` | Show language server status |
| `:OpalToggleDiagnostics` | Toggle diagnostics on/off |

## Key Mappings

The following mappings are set for Opal files when LSP is attached:

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `K` | Show hover information |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>e` | Open diagnostic float |

## Snippets

### UltiSnips

Copy `snippets/opal.snippets` to your UltiSnips directory:
- Vim: `~/.vim/UltiSnips/`
- Neovim: `~/.config/nvim/UltiSnips/`

### LuaSnip

```lua
require("opal_vite.snippets").setup()
```

### Available Snippets

| Trigger | Description |
|---------|-------------|
| `opal-controller` | Basic Stimulus controller |
| `opal-controller-concerns` | Controller with OpalVite concerns |
| `opal-controller-full` | Full controller with state management |
| `opal-service` | Service class |
| `opal-presenter` | Presenter class |
| `qs` | Query selector |
| `qsa` | Query selector all |
| `on` | Event listener |
| `promise` | PromiseV2 block |
| `native` | Native() JS wrapper |
| `toast_success` | Success toast |
| `storage_get` | Get from localStorage |
| `storage_set` | Set in localStorage |

## LSP Diagnostics

The language server warns about Ruby patterns that don't work in Opal:

```ruby
# Warning: Thread is not supported in Opal
Thread.new { puts "This won't work" }

# Warning: File operations not available in browser
File.read("config.yml")

# Warning: Native extension not available
require 'nokogiri'
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    opal-language-server                      │
│  (Shared: patterns, snippets, diagnostics logic)            │
└─────────────────────────────────────────────────────────────┘
        ▲                    ▲                    ▲
        │ LSP               │ LSP               │ LSP
        │                    │                    │
┌───────┴───────┐   ┌───────┴───────┐   ┌───────┴───────┐
│   VS Code     │   │   IntelliJ    │   │  Vim/Neovim   │
│   Extension   │   │   (LSP4IJ)    │   │   (this pkg)  │
└───────────────┘   └───────────────┘   └───────────────┘
```

## Related Packages

- [opal-language-server](../opal-language-server) - The LSP server
- [vscode-opal-vite](../vscode-opal-vite) - VS Code extension
- [vite-plugin-opal](../vite-plugin-opal) - Vite plugin

## License

MIT

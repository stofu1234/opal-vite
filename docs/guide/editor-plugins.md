# Editor Plugins

opal-vite provides editor plugins for enhanced development experience with LSP support, diagnostics, and code snippets.

## Features

All editor plugins provide:

- **LSP Integration**: Full Language Server Protocol support
- **Diagnostics**: Warnings for Opal-incompatible Ruby patterns
- **Code Snippets**: 40+ snippets for Stimulus controllers and OpalVite concerns
- **Auto-detection**: Automatically identifies Opal files in `app/opal/` directories

## Vim / Neovim

### Requirements

| Requirement | Version |
|-------------|---------|
| Neovim | 0.8.0+ (0.11+ recommended) |
| Node.js | 18+ |
| nvim-lspconfig | Required |

### Installation with lazy.nvim

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
  -- Load from packages/vim-opal-vite subdirectory
  opts = {
    rtp = "packages/vim-opal-vite"
  }
}
```

### Installation with packer.nvim

```lua
use {
  "stofu1234/opal-vite",
  rtp = "packages/vim-opal-vite",
  requires = { "neovim/nvim-lspconfig" },
  config = function()
    require("opal_vite").setup()
  end,
}
```

### Installation with vim-plug

```vim
Plug 'neovim/nvim-lspconfig'
Plug 'stofu1234/opal-vite', { 'rtp': 'packages/vim-opal-vite' }
```

Then add to your init.lua:

```lua
require("opal_vite").setup({
  enable_diagnostics = true,
  diagnostic_severity = "warn",
})
```

### Configuration Options

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

### Commands

| Command | Description |
|---------|-------------|
| `:OpalInfo` | Show language server status |
| `:OpalRestart` | Restart the language server |
| `:OpalToggleDiagnostics` | Toggle diagnostics on/off |

### Key Mappings

When LSP is attached to an Opal file:

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `K` | Show hover information |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `<leader>e` | Open diagnostic float |

## VS Code

### Installation

Search for "Opal Vite" in the VS Code Extensions marketplace, or install from command line:

```bash
code --install-extension stofu1234.vscode-opal-vite
```

### Features

- Real-time diagnostics for Opal-incompatible patterns
- Code snippets for Stimulus controllers
- Automatic Opal file detection

## IntelliJ IDEA

### Installation

1. Open Settings/Preferences
2. Go to Plugins > Marketplace
3. Search for "Opal Vite"
4. Click Install

Or install from JetBrains Marketplace:
[Opal Vite Plugin](https://plugins.jetbrains.com/plugin/opal-vite)

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

## Available Snippets

| Trigger | Description |
|---------|-------------|
| `opal-controller` | Basic Stimulus controller |
| `opal-controller-concerns` | Controller with OpalVite concerns |
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

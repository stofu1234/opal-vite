# Opal Language Server

Language Server Protocol (LSP) implementation for Opal (Ruby to JavaScript) development.

This package provides IDE-agnostic language features that can be used by any editor supporting LSP.

## Features

- **Diagnostics**: Detects and reports Opal-incompatible Ruby code
- **Completions**: Code snippets for common Opal patterns
- **Shared Data**: IDE-independent pattern and snippet definitions

## Usage

### As a Standalone Server

```bash
npx opal-language-server --stdio
```

### As a Library

```typescript
import { getIncompatiblePatterns, getHintPatterns } from 'opal-language-server/patterns';
import { getSnippets, convertAllSnippetsToVSCode } from 'opal-language-server/snippets';

// Get all incompatible patterns
const patterns = getIncompatiblePatterns();

// Get all snippets
const snippets = getSnippets();

// Convert snippets to VS Code format
const vscodeSnippets = convertAllSnippetsToVSCode();
```

## Data Files

The shared data files are located in the `data/` directory:

- `incompatible-patterns.json`: Ruby patterns that don't work in Opal
- `snippets.json`: Code snippets for Opal development

### Pattern Categories

| Category | Description |
|----------|-------------|
| threading | Thread, Mutex, Queue (JS is single-threaded) |
| filesystem | File, Dir, IO operations |
| process | system, exec, fork, spawn |
| networking | Socket operations |
| runtime | ObjectSpace, GC |
| encoding | Encoding operations |
| metaprogramming | TracePoint, Binding |
| native-extensions | C extension gems |
| concurrency | Fiber |

### Snippet Categories

| Category | Description |
|----------|-------------|
| stimulus | Stimulus controller snippets |
| patterns | Service, Presenter patterns |
| concerns | OpalVite::Concerns includes |
| native | Native JavaScript blocks |
| dom | DOM manipulation helpers |
| storage | localStorage/sessionStorage |
| toast | Toast notifications |
| encoding | Base64, URI encoding |
| async | Promise, fetch patterns |

## IDE Integration

### VS Code

Use the `vscode-opal-vite` extension which includes this language server.

### IntelliJ / RubyMine

Use the LSP4IJ plugin and configure it to use this language server:

```
Server: npx opal-language-server --stdio
File patterns: *.rb, *.opal
```

### Vim / Neovim

With nvim-lspconfig:

```lua
require('lspconfig.configs').opal = {
  default_config = {
    cmd = { 'npx', 'opal-language-server', '--stdio' },
    filetypes = { 'ruby', 'opal' },
    root_dir = function(fname)
      return require('lspconfig').util.find_git_ancestor(fname)
    end,
  },
}

require('lspconfig').opal.setup{}
```

### Emacs

With lsp-mode:

```elisp
(lsp-register-client
  (make-lsp-client
    :new-connection (lsp-stdio-connection '("npx" "opal-language-server" "--stdio"))
    :major-modes '(ruby-mode)
    :server-id 'opal-ls))
```

## API

### Patterns Module

```typescript
import {
  loadPatterns,
  getIncompatiblePatterns,
  getHintPatterns,
  getCategories,
  compilePattern,
  getPatternsByCategory,
  getPatternsBySeverity
} from 'opal-language-server/patterns';
```

### Snippets Module

```typescript
import {
  loadSnippets,
  getSnippets,
  getSnippetCategories,
  getSnippetsByCategory,
  convertAllSnippetsToVSCode,
  convertAllSnippetsToIntelliJ,
  getAllCompletionItems
} from 'opal-language-server/snippets';
```

## Development

```bash
# Install dependencies
npm install

# Build
npm run build

# Watch mode
npm run dev

# Run tests
npm test
```

## License

MIT

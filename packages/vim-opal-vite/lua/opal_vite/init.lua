-- opal_vite.nvim - Neovim plugin for Opal development with Vite
-- Provides LSP integration, snippets, and diagnostics for Opal (Ruby to JavaScript)

local M = {}

-- Compatibility: vim.lsp.get_clients was added in Neovim 0.10
-- Older versions use vim.lsp.get_active_clients
local function get_lsp_clients(opts)
  if vim.lsp.get_clients then
    return vim.lsp.get_clients(opts)
  else
    -- Fallback for Neovim < 0.10
    local clients = vim.lsp.get_active_clients(opts)
    if opts and opts.name then
      return vim.tbl_filter(function(c)
        return c.name == opts.name
      end, clients)
    end
    return clients
  end
end

-- Default configuration
M.config = {
  -- Enable LSP diagnostics
  enable_diagnostics = true,
  -- Diagnostic severity: "error", "warn", "info", "hint"
  diagnostic_severity = "warn",
  -- Auto-detect Opal files in app/opal/ directories
  auto_detect_opal_files = true,
  -- Path to opal-language-server (default: use npx)
  server_cmd = nil,
  -- Additional LSP settings
  lsp_settings = {},
}

-- Setup function to initialize the plugin
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Setup LSP if nvim-lspconfig is available
  local ok, lsp = pcall(require, "opal_vite.lsp")
  if ok then
    lsp.setup(M.config)
  end

  -- Register autocommands
  M.setup_autocommands()

  -- Setup user commands
  M.setup_commands()
end

-- Setup autocommands for Opal file detection
function M.setup_autocommands()
  local group = vim.api.nvim_create_augroup("OpalVite", { clear = true })

  if M.config.auto_detect_opal_files then
    -- Mark Ruby files in app/opal/ as Opal files
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      group = group,
      pattern = { "*/app/opal/**/*.rb", "*/opal/**/*.rb" },
      callback = function()
        vim.b.opal_file = true
        vim.bo.commentstring = "# %s"
      end,
    })
  end
end

-- Setup user commands
function M.setup_commands()
  vim.api.nvim_create_user_command("OpalRestart", function()
    local ok, lsp = pcall(require, "opal_vite.lsp")
    if ok then
      lsp.restart()
    end
  end, { desc = "Restart Opal Language Server" })

  vim.api.nvim_create_user_command("OpalInfo", function()
    M.show_info()
  end, { desc = "Show Opal Language Server info" })

  vim.api.nvim_create_user_command("OpalToggleDiagnostics", function()
    M.toggle_diagnostics()
  end, { desc = "Toggle Opal diagnostics" })
end

-- Show info about the Opal Language Server
function M.show_info()
  local clients = get_lsp_clients({ name = "opal_language_server" })
  if #clients > 0 then
    local client = clients[1]
    print(string.format(
      "Opal Language Server: Active (ID: %d, Root: %s)",
      client.id,
      client.config.root_dir or "N/A"
    ))
  else
    print("Opal Language Server: Not running")
  end
end

-- Toggle diagnostics
function M.toggle_diagnostics()
  M.config.enable_diagnostics = not M.config.enable_diagnostics

  if M.config.enable_diagnostics then
    print("Opal diagnostics: Enabled")
    -- Trigger diagnostics refresh
    vim.cmd("edit")
  else
    print("Opal diagnostics: Disabled")
    -- Clear diagnostics
    vim.diagnostic.reset()
  end
end

-- Check if current buffer is an Opal file
function M.is_opal_file()
  if vim.b.opal_file then
    return true
  end

  local path = vim.fn.expand("%:p")
  if path:match("/app/opal/") or path:match("/opal/") then
    return true
  end

  return false
end

return M

-- LSP configuration for Opal Language Server
-- Integrates with nvim-lspconfig for seamless LSP support

local M = {}

local config = {}

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

-- Setup LSP for Opal
function M.setup(opts)
  config = opts or {}

  -- Check if lspconfig is available
  local ok, lspconfig = pcall(require, "lspconfig")
  if not ok then
    vim.notify(
      "nvim-lspconfig not found. Install it for LSP support: https://github.com/neovim/nvim-lspconfig",
      vim.log.levels.WARN
    )
    return
  end

  -- Check if custom server config is needed
  local configs = require("lspconfig.configs")

  -- Register the Opal Language Server if not already registered
  if not configs.opal_language_server then
    configs.opal_language_server = {
      default_config = {
        cmd = M.get_server_cmd(),
        filetypes = { "ruby" },
        root_dir = lspconfig.util.root_pattern(
          "vite.config.ts",
          "vite.config.js",
          "Gemfile",
          ".git"
        ),
        single_file_support = true,
        settings = {
          opalVite = {
            enableDiagnostics = config.enable_diagnostics,
            diagnosticSeverity = config.diagnostic_severity,
            autoDetectOpalFiles = config.auto_detect_opal_files,
          },
        },
      },
    }
  end

  -- Setup the server
  lspconfig.opal_language_server.setup(vim.tbl_deep_extend("force", {
    on_attach = M.on_attach,
    capabilities = M.get_capabilities(),
    settings = config.lsp_settings,
  }, config.lsp_opts or {}))
end

-- Get the server command
function M.get_server_cmd()
  if config.server_cmd then
    if type(config.server_cmd) == "string" then
      return { config.server_cmd, "--stdio" }
    end
    return config.server_cmd
  end

  -- Default: use npx to run the server
  return { "npx", "opal-language-server", "--stdio" }
end

-- Get LSP capabilities
function M.get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  -- Add cmp capabilities if available
  local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end

  return capabilities
end

-- On attach callback
function M.on_attach(client, bufnr)
  -- Only enable for Opal files (in app/opal/ or opal/ directories)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local is_opal = filepath:match("/app/opal/") or filepath:match("/opal/")

  if not is_opal and config.auto_detect_opal_files then
    -- Detach from non-Opal Ruby files if auto-detection is enabled
    vim.lsp.stop_client(client.id, true)
    return
  end

  -- Set buffer-local keymaps
  local opts = { buffer = bufnr, silent = true }

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)

  -- Mark buffer as Opal file
  vim.b[bufnr].opal_file = true
end

-- Restart the Opal Language Server
function M.restart()
  local clients = get_lsp_clients({ name = "opal_language_server" })
  for _, client in ipairs(clients) do
    local bufs = vim.lsp.get_buffers_by_client_id(client.id)
    vim.lsp.stop_client(client.id, true)

    -- Wait a bit and restart
    vim.defer_fn(function()
      for _, buf in ipairs(bufs) do
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("edit")
        end)
      end
    end, 500)
  end

  print("Opal Language Server restarted")
end

return M

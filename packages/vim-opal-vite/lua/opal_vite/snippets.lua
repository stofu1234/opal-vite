-- LuaSnip snippets for Opal development
-- These can be loaded with: require("luasnip.loaders.from_lua").load({ paths = { "path/to/this/file" } })

local M = {}

-- Check if LuaSnip is available
local function get_luasnip()
  local ok, ls = pcall(require, "luasnip")
  if not ok then
    return nil
  end
  return ls
end

-- Setup LuaSnip snippets
function M.setup()
  local ls = get_luasnip()
  if not ls then
    vim.notify("LuaSnip not found. Snippets will not be available.", vim.log.levels.WARN)
    return
  end

  local s = ls.snippet
  local t = ls.text_node
  local i = ls.insert_node
  local c = ls.choice_node
  local f = ls.function_node

  -- Helper to create multiline text nodes
  local function lines(...)
    local result = {}
    for _, line in ipairs({ ... }) do
      table.insert(result, line)
      table.insert(result, "")
    end
    -- Remove last empty string
    table.remove(result)
    return result
  end

  local snippets = {
    -- Stimulus Controller
    s("opal-controller", {
      t(lines(
        "require 'opal_stimulus'",
        "",
        "class "
      )),
      i(1, "Name"),
      t(lines(
        "Controller < StimulusController",
        "  def initialize",
        "    super",
        "  end",
        "",
        "  def connect",
        "    "
      )),
      i(2),
      t(lines(
        "",
        "  end",
        "",
        "  def disconnect",
        "    "
      )),
      i(3),
      t(lines(
        "",
        "  end",
        "end"
      )),
    }),

    -- Stimulus Controller with Concerns
    s("opal-controller-concerns", {
      t(lines(
        "require 'opal_stimulus'",
        "require 'opal_vite'",
        "",
        "class "
      )),
      i(1, "Name"),
      t(lines(
        "Controller < StimulusController",
        "  include OpalVite::Concerns::V1::DomHelpers",
        "  include OpalVite::Concerns::V1::"
      )),
      c(2, {
        t("StimulusHelpers"),
        t("Storable"),
        t("Toastable"),
        t("JsProxyEx"),
        t("ValidationHelpers"),
      }),
      t(lines(
        "",
        "",
        "  def initialize",
        "    super",
        "  end",
        "",
        "  def connect",
        "    "
      )),
      i(3),
      t(lines(
        "",
        "  end",
        "",
        "  def disconnect",
        "    "
      )),
      i(4),
      t(lines(
        "",
        "  end",
        "end"
      )),
    }),

    -- Service Class
    s("opal-service", {
      t(lines(
        "require 'opal_vite'",
        "",
        "class "
      )),
      i(1, "Name"),
      t(lines(
        "Service",
        "  include OpalVite::Concerns::V1::DomHelpers",
        "  include OpalVite::Concerns::V1::Storable",
        "",
        "  def initialize",
        "    "
      )),
      i(2),
      t(lines(
        "",
        "  end",
        "",
        "  def "
      )),
      i(3, "method_name"),
      t(lines(
        "",
        "    "
      )),
      i(4),
      t(lines(
        "",
        "  end",
        "end"
      )),
    }),

    -- Presenter Class
    s("opal-presenter", {
      t(lines(
        "require 'opal_vite'",
        "",
        "class "
      )),
      i(1, "Name"),
      t(lines(
        "Presenter",
        "  include OpalVite::Concerns::V1::DomHelpers",
        "",
        "  def initialize(container)",
        "    @container = container",
        "  end",
        "",
        "  def render",
        "    html = <<~HTML",
        '      <div class="'
      )),
      i(2, "class"),
      t(lines(
        '">',
        "        "
      )),
      i(3),
      t(lines(
        "",
        "      </div>",
        "    HTML",
        "    @container.innerHTML = html",
        "  end",
        "end"
      )),
    }),

    -- DOM Helpers
    s("qs", {
      t("qs('"),
      i(1, "selector"),
      t("')"),
      i(0),
    }),

    s("qsa", {
      t("qsa('"),
      i(1, "selector"),
      t("')"),
      i(0),
    }),

    s("qsi", {
      t("qsi('"),
      i(1, "id"),
      t("')"),
      i(0),
    }),

    s("on", {
      t("on("),
      i(1, "element"),
      t(", '"),
      i(2, "event"),
      t(lines(
        "') do |e|",
        "  "
      )),
      i(3),
      t(lines(
        "",
        "end"
      )),
    }),

    -- Promise
    s("promise", {
      t(lines(
        "PromiseV2.new do |resolve, reject|",
        "  "
      )),
      i(1),
      t(lines(
        "",
        "end"
      )),
    }),

    -- Native JS
    s("native", {
      t("Native(`"),
      i(1, "javascript"),
      t("`)"),
      i(0),
    }),

    -- Toast
    s("toast_success", {
      t("toast_success('"),
      i(1, "message"),
      t("')"),
    }),

    s("toast_error", {
      t("toast_error('"),
      i(1, "message"),
      t("')"),
    }),

    -- Storage
    s("storage_get", {
      t("storage_get('"),
      i(1, "key"),
      t("')"),
      i(0),
    }),

    s("storage_set", {
      t("storage_set('"),
      i(1, "key"),
      t("', "),
      i(2, "value"),
      t(")"),
    }),
  }

  -- Add snippets for ruby filetype
  ls.add_snippets("ruby", snippets)

  vim.notify("Opal snippets loaded", vim.log.levels.INFO)
end

return M

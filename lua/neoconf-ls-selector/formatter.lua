local neoconf = require 'neoconf'

local M = {}

local function populate_target_formatters(filetype)
  local g_fmts = neoconf.get('ls-selector._.formatters', {})
  l_fmts = filetype
      and neoconf.get(
        string.format('ls-selector.%s.formatters', filetype),
        {}
      )
    or {}
  return vim.tbl_deep_extend('force', g_fmts, l_fmts) or {}
end

function M.format(opts)
  local bufnr = (opts or {}).bufnr or 0
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
  local formatters =
    populate_target_formatters(filetype ~= '' and filetype or nil)

  local used = {}
  opts = vim.tbl_deep_extend('force', {
    filter = function(client)
      local uses = vim.tbl_contains(formatters, client.name, nil)
      if uses then
        table.insert(used, client.name)
      end
      return uses
    end,
  }, opts or {})

  vim.lsp.buf.format(opts)

  vim.notify(string.format('formatted by: [%s]', table.concat(used, ', ')))
end

return M

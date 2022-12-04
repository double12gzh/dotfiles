vim.cmd.packadd 'cmp-nvim-lsp'

local M = {}

local custom_init = function(client)
  client.config.flags = client.config.flags or {}
  client.config.flags.allow_incremental_sync = true
end

-- Enable (broadcasting) snippet capability for completion.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
--}}}

local augroup_format = vim.api.nvim_create_augroup('my_lsp_format', { clear = true })
local autocmd_format = function(async, filter)
  vim.api.nvim_clear_autocmds { buffer = 0, group = augroup_format }
  vim.api.nvim_create_autocmd('BufWritePre', {
    buffer = 0,
    callback = function()
      vim.lsp.buf.format { async = async, filter = filter }
    end,
  })
end
local format_mapping = function(client, bufnr, filter)
  vim.keymap.set('n', '<Leader>lf', function()
    vim.lsp.buf.format { async = false, filter = filter }
  end, { noremap = true, silent = true, buffer = bufnr })
end

local nullls_filter = function(c)
  return c.name == 'null-ls'
end

local filetype_attach = setmetatable({
  cpp = function(client, bufnr)
    format_mapping(client, bufnr)
  end,

  go = function(client, bufnr)
    format_mapping(client, bufnr)
  end,

  rust = function(client, bufnr)
    autocmd_format(false)
    format_mapping(client, bufnr)
  end,

  lua = function(client, bufnr)
    -- disable sumneko_lua format
    if client.name == 'sumneko_lua' then
      client.server_capabilities.documentFormattingProvider = false -- 0.8 and later
      client.server_capabilities.documentRangeFormattingProvider = false
    end

    autocmd_format(false, nullls_filter)
    format_mapping(client, bufnr, nullls_filter)
  end,

  bzl = function(client, bufnr)
    autocmd_format(true, nullls_filter)
    format_mapping(client, bufnr, nullls_filter)
  end,

  markdown = function(client, bufnr)
    format_mapping(client, bufnr, nullls_filter)
  end,

  yaml = function(client, bufnr)
    format_mapping(client, bufnr, nullls_filter)
  end,

  html = function(client, bufnr)
    format_mapping(client, bufnr, nullls_filter)
  end,

  css = function(client, bufnr)
    format_mapping(client, bufnr, nullls_filter)
  end,

  scss = function(client, bufnr)
    format_mapping(client, bufnr, nullls_filter)
  end,

  less = function(client, bufnr)
    format_mapping(client, bufnr, nullls_filter)
  end,

  javascript = function(client, bufnr)
    format_mapping(client, bufnr, nullls_filter)
  end,

  typescript = function(client, bufnr)
    format_mapping(client, bufnr, nullls_filter)
  end,

  typescriptreact = function(client, bufnr)
    format_mapping(client, bufnr, nullls_filter)
  end,
}, {
  __index = function()
    return function(client, bufnr) end
  end,
})

local fix_null_errors = function()
  local default_exe_handler = vim.lsp.handlers['workspace/executeCommand']
  vim.lsp.handlers['workspace/executeCommand'] = function(err, ...)
    -- supress NULL_LS error msg
    local prefix = 'NULL_LS'
    if err and err.message:sub(1, #prefix) == prefix then
      return
    end
    return default_exe_handler(err, ...)
  end
end

local function lsp_keymaps(bufnr)
	local opts = { noremap = true, silent = true }
	local keymap = vim.api.nvim_buf_set_keymap

	keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
	keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
	-- keymap('n', '<Leader>gd', '<cmd>Telescope lsp_definitions<CR>', opts)
	keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
	keymap(bufnr, "n", "gI", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	-- keymap(bufnr, 'n', '<Leader>gi', '<cmd>Telescope lsp_implementations<CR>', opts)
	keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
	-- keymap(bufnr, 'n', '<Leader>gr', '<cmd>Telescope lsp_references<CR>', opts)
	keymap(bufnr, "n", "<Leader>lf", "<cmd>lua vim.lsp.buf.format{ async = true }<cr>", opts)
	keymap(bufnr, "n", "<Leader>li", "<cmd>LspInfo<cr>", opts)
	keymap(bufnr, "n", "<Leader>lI", "<cmd>LspInstallInfo<cr>", opts)
	keymap(bufnr, "n", "<Leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
	keymap(bufnr, "n", "<Leader>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<cr>", opts)
	keymap(bufnr, "n", "<Leader>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", opts)
	keymap(bufnr, "n", "<Leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
	keymap(bufnr, "n", "<Leader>ls", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	keymap(bufnr, "n", "<Leader>lq", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
	keymap(bufnr, "n", "<Leader>es", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
	keymap(bufnr, "n", "<Leader>ee", "<cmd>lua vim.diagnostic.open_float(nil, { scope = 'line' })<CR>", opts)
end

local custom_attach = function(client, bufnr)
  -- The first time some LSP servers are not attached currectly, therefore we
  -- force another read just once.
  if not vim.g._lsp_loaded_successfully then
    vim.g._lsp_loaded_successfully = true
  end

  lsp_keymaps(bufnr)

  -- filetype config
  local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  filetype_attach[filetype](client, bufnr)
  fix_null_errors()
end

M.default = function(configs)
  local custom_config = {
    on_init = custom_init,
    on_attach = custom_attach,
    capabilities = capabilities,
  }
  if configs ~= nil then
    for key, value in pairs(configs) do
      custom_config[key] = value
    end
  end
  return custom_config
end

return M

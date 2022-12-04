local lspconfig = require 'lspconfig'
local c = require 'user.config.lsp.customs'
local M = {}

M.setup = function()
  -- lspconfig.phpactor.setup(c.default {
  --   init_options = {
  --     ['language_server_phpstan.enabled'] = true,
  --   },
  -- })
  lspconfig.intelephense.setup(c.default {})
end

return M

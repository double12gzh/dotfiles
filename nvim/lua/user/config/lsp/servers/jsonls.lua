local c = require 'user.config.lsp.customs'
local lspconfig = require 'lspconfig'

vim.cmd.packadd 'schemastore.nvim'

local setup = function()
  lspconfig.jsonls.setup(c.default {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  })
end

return {
  setup = setup,
}

local lspconfig = require 'lspconfig'
local c = require 'user.config.lsp.customs'

-- vim.cmd.packadd 'neodev.nvim'

local setup = function()
  lspconfig.sumneko_lua.setup(c.default {
    settings = {
      Lua = {
        telemetry = { enable = false },
        runtime = { version = 'LuaJIT' },
        diagnostics = {
          globals = { 'vim', 'packer_plugins', 'planery' },
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file('', true),
        },
      },
    },
  })
end

return {
  setup = setup,
}

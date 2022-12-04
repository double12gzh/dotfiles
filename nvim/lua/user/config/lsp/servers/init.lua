local lspconfig = require 'lspconfig'
local c = require 'user.config.lsp.customs'

for _, server in ipairs {
  'php',
  'jsonls',
  'yamlls',
  'clangd',
  'gopls',
  'rust',
  'sumneko_lua',
  'null-ls',
} do
  require('user.config.lsp.servers.' .. server).setup()
end

-- some others use default config
for _, server in ipairs {
  'html',
  'cssls',
  'tsserver',
  'pyright',
  'eslint',
  'bashls',
  'cmake',
  'texlab',
  'vimls',
} do
  lspconfig[server].setup(c.default())
end

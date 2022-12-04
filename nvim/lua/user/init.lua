--Remap space as leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'user.plugins'
require 'user.options'
require 'user.autocmd'

vim.schedule(function()
  require 'user.commands'
  require 'user.mappings'
end)

-- stylua: ignore start
vim.defer_fn(function()vim.cmd.doautocmd 'User LoadTicker1' end, 100)
vim.defer_fn(function()vim.cmd.doautocmd 'User LoadTicker2' end, 300)
vim.defer_fn(function()vim.cmd.doautocmd 'User LoadTicker3' end, 600)
vim.defer_fn(function()vim.cmd.doautocmd 'User LoadTicker4' end, 900)
-- stylua: ignore end

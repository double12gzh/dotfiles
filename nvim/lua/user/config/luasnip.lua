local ls = require 'luasnip'
local types = require 'luasnip.util.types'

ls.config.setup {
  history = true,
  updateevents = 'TextChanged,TextChangedI',
  delete_check_events = 'TextChanged',
  -- Autosnippets:
  enable_autosnippets = true,
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { ' « ', 'Comment' } },
      },
    },
  },
}

vim.keymap.set({ 'i', 's' }, '<C-n>', function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end, {})

vim.keymap.set({ 'i', 's' }, '<C-p>', function()
  if ls.choice_active() then
    ls.change_choice(-1)
  end
end, {})

require 'user.snips.all'
require 'user.snips.c'
require 'user.snips.cpp'
require 'user.snips.rust'
require 'user.snips.go'
require 'user.snips.lua'
require 'user.snips.markdown'

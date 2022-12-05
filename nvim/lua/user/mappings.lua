local function termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local opts = { noremap = true, silent = true }

-- stylua: ignore start

-- fold/unfold
-- zc/zo/zr/zm

-- Normal --
-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- NvimTree --
vim.keymap.set("n", "<F2>", "<cmd>:NvimTreeToggle<CR>", opts)
-- Aerial --
vim.keymap.set('n', '<F3>', "<cmd>:AerialToggle<CR>", opts)

vim.keymap.set("n", "<Esc><Esc>", ":noh<CR>", { silent = true, desc = "clear hlsearch" })
vim.keymap.set("n", "<Leader>hh", ":h <CR>", { desc = "show help for work under the cursor" })

-- Yank related {{{
vim.keymap.set("n", "<Leader>y", '"+y')
vim.keymap.set("x", "<Leader>y", '"+y')
vim.keymap.set("n", "<Leader>p", '"+p')
vim.keymap.set("n", "<Leader>P", '"+P')

vim.keymap.set("x", "p", '"_dP',
  { desc = 'replace visually selected with the " contents' }
)
--}}}

-- bash like {{{
vim.keymap.set('i', '<C-a>', '<Home>')
vim.keymap.set('i', '<C-e>', '<End>')
-- }}}

-- Navigate buffers
vim.keymap.set("n", "<S-l>", ":bnext<CR>", opts)
vim.keymap.set("n", "<S-h>", ":bprevious<CR>", opts)
vim.keymap.set('n', '<Leader>bf', '<cmd>bfirst<CR>')
vim.keymap.set('n', '<Leader>bl', '<cmd>blast<CR>')
-- }}}

-- window {{{
vim.keymap.set('n', '<C-S-Up>', function() require('smart-splits').resize_up() end)
vim.keymap.set('n', '<C-S-Down>', function() require('smart-splits').resize_down() end)
vim.keymap.set('n', '<C-S-Left>', function() require('smart-splits').resize_left() end)
vim.keymap.set('n', '<C-S-Right>', function() require('smart-splits').resize_right() end)
-- }}}

-- command
-- vim.keymap.set('c', '<C-a>', '<Home>')
-- vim.keymap.set('c', '<C-e>', '<End>')
-- vim.keymap.set('c', '<C-b>', '<S-Left>')
-- vim.keymap.set('c', '<C-f>', '<S-Right>')
-- vim.keymap.set('c', '<C-h>', '<Left>')
-- vim.keymap.set('c', '<C-l>', '<Right>')

-- terminal
vim.keymap.set('t', '<Esc>', termcodes '<C-\\><C-N>')

-- easyalign
vim.keymap.set('n', 'ga', '<Plug>(EasyAlign)')
vim.keymap.set('x', 'ga', '<Plug>(EasyAlign)')

-- floaterm
vim.keymap.set('n', '<F4>', '<cmd>FloatermToggle<CR>')
vim.keymap.set('t', '<C-n>', termcodes '<C-\\><C-N>:FloatermNew<CR>')
vim.keymap.set('t', '<C-k>', termcodes '<C-\\><C-N>:FloatermPrev<CR>')
vim.keymap.set('t', '<C-j>', termcodes '<C-\\><C-N>:FloatermNext<CR>')
vim.keymap.set('t', '<F4>', termcodes '<C-\\><C-N>:FloatermToggle<CR>')
vim.keymap.set('t', '<C-d>', termcodes '<C-\\><C-N>:FloatermKill<CR>')

-- asynctask
-- vim.keymap.set('n', '<C-x>', '<cmd>AsyncTask build-and-run<CR>')
-- vim.keymap.set('n', '<C-b>', '<cmd>AsyncTask build<CR>')
-- vim.keymap.set('n', '<C-r>', '<cmd>AsyncTask run<CR>')

-- hop
vim.keymap.set('n', '<Leader>jj', function() require('hop').hint_lines() end)
vim.keymap.set('n', '<Leader>ss', function() require('hop').hint_patterns() end)

-- accelerate
vim.keymap.set('n', 'j', '<Plug>(accelerated_jk_gj)')
vim.keymap.set('n', 'k', '<Plug>(accelerated_jk_gk)')

-- git
vim.keymap.set('n', '<Leader>hb', function() require('gitsigns').blame_line {full = true} end)
vim.keymap.set('n', '<Leader>hd', function() require('gitsigns').diffthis() end)

-- markdown
vim.keymap.set('n', '<Leader>mp', '<cmd>MarkdownPreview<CR>')

-- telescope {{{
vim.keymap.set('n', '<F5>', "<cmd>Telescope find_files<CR>")
vim.keymap.set('n', '<F6>', "<cmd>Telescope live_grep<CR>")
vim.keymap.set('n', '<F7>', "<cmd>Telescope grep_string<CR>")
vim.keymap.set('n', '<Leader>bb', "<cmd>Telescope buffers<CR>")
vim.keymap.set('n', '<Leader>fc', "<cmd>Telescope command<CR>")
vim.keymap.set('n', '<Leader>ts', "<cmd>Telescope tasks<CR>")
-- }}}
-- stylua: ignore end

-- vim: fdm=marker fdl=0

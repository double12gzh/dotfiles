require('aerial').setup {
  backends = { 'lsp', 'treesitter', 'markdown' },
  layout = {
    default_direction = 'prefer_right',
    placement = 'edge',
  },
  attach_mode = 'global', -- 'window' | 'global'
  nerd_font = 'auto',
  show_guides = true,
}

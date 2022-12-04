require('smart-splits').setup {
  ignored_filetypes = {
    'nofile',
    'quickfix',
    'NvimTree',
    'Outline',
    'qf',
    'prompt',
  },
  ignored_buftypes = { 'NvimTree', 'Outline' },
  resize_mode = {
    quit_key = '<ESC>',
    silent = true,
  },
}

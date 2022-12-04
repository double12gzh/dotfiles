require('pretty-fold').setup {
  fill_char = '-',
  comment_signs = {},
  keep_indentation = false,
  sections = {
    left = {
      ' »» ',
      function()
        return string.rep('-', vim.v.foldlevel)
      end,
      'content',
    },
    right = {
      ' «« ',
      '[ ',
      'number_of_folded_lines',
      ']',
      function(config)
        return config.fill_char:rep(3)
      end,
    },
  },
}

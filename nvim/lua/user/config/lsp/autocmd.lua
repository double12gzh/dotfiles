local lsp_events_group = vim.api.nvim_create_augroup('LSP_EVENTS', { clear = true })

vim.api.nvim_create_autocmd('BufWritePre', {
  group = lsp_events_group,
  pattern = '*.go',
  callback = function()
    require('user.config.lsp.servers.gopls').org_imports(5000)
  end,
})

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  group = lsp_events_group,
  pattern = { '*.go', 'go.mod' },
  callback = function()
    vim.api.nvim_create_user_command('GoAddTagsJson', function()
      require('user.go.tags').add('json', '-transform', 'snakecase', '--skip-unexported')
    end, { nargs = 0 })

    vim.api.nvim_create_user_command('GoAddTagsXml', function()
      require('user.go.tags').add('xml', '-transform', 'snakecase', '--skip-unexported')
    end, { nargs = 0 })

    vim.api.nvim_create_user_command('GoRmTagsJson', function()
      require('user.go.tags').rm 'json'
    end, { nargs = 0 })

    vim.api.nvim_create_user_command('GoRmTagsXml', function()
      require('user.go.tags').rm 'xml'
    end, { nargs = 0 })

    vim.api.nvim_create_user_command('GoImpl', function(opts)
      require('user.go.impl').run(unpack(opts.fargs))
    end, { complete = require('user.go.impl').complete, nargs = '*' })

    vim.api.nvim_create_user_command('GoTestFile', function()
      require('user.go.gotest').run_file()
    end, { nargs = 0 })

    vim.api.nvim_create_user_command('GoTest', function()
      require('user.go.gotest').list_tests()
    end, { nargs = 0 })

    vim.api.nvim_create_user_command('GoMockGen', require('user.go.mockgen').run, {
      nargs = '*',
      complete = function(_, _, _)
        return { '-p', '-d', '-i', '-s' }
      end,
    })
  end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  group = lsp_events_group,
  pattern = 'go.mod',
  callback = function(args)
    require('user.go.gopls').tidy()
  end,
  desc = 'run go mod tidy on save',
})

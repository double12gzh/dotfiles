vim.cmd.packadd 'mason.nvim'
vim.cmd.packadd 'mason-lspconfig.nvim'

require('mason').setup {
    github = {
--        download_url_template="https://ghproxy.com/https://github.com/%s/releases/download/%s/%s"
    },
  ui = {
    border = 'single',
    icons = {
      package_uninstalled = '',
      package_installed = '',
      package_pending = ' ',
    },
    keymaps = {
      -- Keymap to expand a package
      toggle_package_expand = '<CR>',
      -- Keymap to install the package under the current cursor position
      install_package = 'i',
      -- Keymap to reinstall/update the package under the current cursor position
      update_package = 'u',
      -- Keymap to check for new version for the package under the current cursor position
      check_package_version = 'c',
      -- Keymap to update all installed packages
      update_all_packages = 'U',
      -- Keymap to check which installed packages are outdated
      check_outdated_packages = 'C',
      -- Keymap to uninstall a package
      uninstall_package = 'X',
      -- Keymap to cancel a package installation
      cancel_installation = '<C-c>',
      -- Keymap to apply language filter
      apply_language_filter = '<C-f>',
    },
  },
  max_concurrent_installers = 4,
}

require('mason-lspconfig').setup {
    github = {
--        download_url_template="https://ghproxy.com/https://github.com/%s/releases/download/%s/%s"
        -- download_url_template="https://download.fastgit.org/%s/releases/download/%s/%s"
    },
  ensure_installed = {
    'clangd',
    'gopls',
    'sumneko_lua',
    'rust_analyzer',
  },
  automatic_installation = false,
}

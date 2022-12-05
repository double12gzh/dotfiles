local servers = {
	"sumneko_lua",
	"cssls",
	"html",
	"tsserver",
	"pyright",
    "gopls",
    "rust_analyzer",
    "clangd",
	"bashls",
	"jsonls",
	"yamlls",
}

local settings = {
	ui = {
		border = "single",
		icons = {
			package_installed = "",
			package_pending = " ",
			package_uninstalled = "",
		},
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
	log_level = vim.log.levels.INFO,
	max_concurrent_installers = 4,
    github = {
    --    download_url_template="https://ghproxy.com/https://github.com/%s/releases/download/%s/%s",
    },
}

require("mason").setup(settings)
require("mason-lspconfig").setup({
	ensure_installed = servers,
	automatic_installation = true,
    github = {
     --   download_url_template="https://ghproxy.com/https://github.com/%s/releases/download/%s/%s",
    },
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
	return
end

local opts = {}

for _, server in pairs(servers) do
	opts = {
		on_attach = require("user.lsp.handlers").on_attach,
		capabilities = require("user.lsp.handlers").capabilities,
	}

	server = vim.split(server, "@")[1]

	local require_ok, conf_opts = pcall(require, "user.lsp.settings." .. server)
	if require_ok then
		opts = vim.tbl_deep_extend("force", conf_opts, opts)
	end

	lspconfig[server].setup(opts)
end

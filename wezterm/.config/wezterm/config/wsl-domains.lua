local wezterm = require("wezterm")

local M = {}

M.is_linux = wezterm.target_triple == "x86_64-unknown-linux-gnu"
M.is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"
M.wsl_domains = wezterm.default_wsl_domains()

for _, dom in ipairs(M.wsl_domains) do
	if dom.name == "WSL:Ubuntu-Preview" then
		dom.default_prog = { "zsh" }
		dom.username = "work"
		dom.default_cwd = "~"
	end
end

return M

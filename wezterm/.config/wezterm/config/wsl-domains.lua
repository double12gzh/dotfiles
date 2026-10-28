local wezterm = require("wezterm")

local M = {}

M.is_linux = wezterm.target_triple:find("linux") ~= nil
M.is_windows = wezterm.target_triple:find("windows") ~= nil
M.wsl_domains = M.is_windows and wezterm.default_wsl_domains() or {}

for _, dom in ipairs(M.wsl_domains) do
	if dom.name == "WSL:Ubuntu-Preview" then
		dom.default_prog = { "zsh" }
		dom.username = "work"
		dom.default_cwd = "~"
	end
end

return M

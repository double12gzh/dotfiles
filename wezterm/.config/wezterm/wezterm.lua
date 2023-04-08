local wezterm = require("wezterm")

local keybindings = require("config.keybindings")
local wsl_domains = require("config.wsl-domains")

require("config.right-status").setup()
require("config.tab-title").setup()

local gpus = wezterm.gui.enumerate_gpus()
local font = "Hack Nerd Font"
local color_scheme = "Gruvbox dark, medium (base16)"

return {
	leader = { key = ".", mods = "ALT", timeout_milliseconds = 1000 },
	automatically_reload_config = true,
	use_ime = true,
	scrollback_lines = 5000,
	check_for_updates = false,
	window_decorations = "NONE | RESIZE",
	disable_default_mouse_bindings = false,
	audible_bell = "Disabled",
	prefer_egl = true,
	native_macos_fullscreen_mode = true,
	enable_tab_bar = true,
	use_fancy_tab_bar = false,
	tab_bar_at_bottom = false,
	show_tab_index_in_tab_bar = true,
	adjust_window_size_when_changing_font_size = false,
	default_cursor_style = "SteadyBlock",
	force_reverse_video_cursor = false,
	use_cap_height_to_scale_fallback_fonts = true,
	font = wezterm.font(font),
	font_size = 12,
	bold_brightens_ansi_colors = false,
	freetype_load_target = "Normal",
	freetype_load_flags = "NO_HINTING|MONOCHROME",
	color_scheme = color_scheme,
	tab_max_width = 135,
	initial_rows = 35,
	initial_cols = 120,
	window_background_opacity = 1,
	text_background_opacity = 1,
	window_padding = { left = 5, right = 5, top = 5, bottom = 5 },
	webgpu_preferred_adapter = gpus[1],
	keys = keybindings.create_keybinds(),
	-- disable_default_key_bindings = true,
	key_tables = keybindings.key_tables,
	mouse_bindings = keybindings.mouse_bindings,
	enable_scroll_bar = true,
	status_update_interval = 1000,
	hide_tab_bar_if_only_one_tab = false,
	hide_mouse_cursor_when_typing = false,
	switch_to_last_active_tab_when_closing_tab = true,
	inactive_pane_hsb = { saturation = 1.0, brightness = 1.0 },
	-- window_close_confirmation = "NeverPrompt",
	window_frame = {
		active_titlebar_bg = "#090909",
		font = wezterm.font(font, { bold = true }),
		font_size = 9,
	},
	--background = {
	--	{
	--		source = { File = wezterm.config_dir .. "/pictures/astro-jelly.jpg" },
	--	},
	--},

	-- wsl config
	-- {{
	wsl_domains = wsl_domains.wsl_domains,
	default_domain = wsl_domains.is_windows and "WSL:Ubuntu-Preview" or nil,
	default_prog = wsl_domains.is_windows and { "wsl.exe" } or nil,
	--launch_menu = wsl_domains.is_windows and { { args = { "wsl.exe" }, domain = { DomainName = "local" } } } or nil,
	set_environment_variables = {
		TERMINFO_DIRS = "/home/" .. (os.getenv("USERNAME") or os.getenv("USER")) .. "/.nix-profile/share/terminfo",
		WSLENV = "TERMINFO_DIRS",
		prompt = wsl_domains.is_windows and "$E]7;file://localhost/$P$E\\$E[32m$T$E[0m $E[35m$P$E[36m$_$G$E[0m " or nil,
	},
	-- }}
}

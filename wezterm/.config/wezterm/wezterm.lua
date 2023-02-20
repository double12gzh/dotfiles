local wezterm = require("wezterm")
local keybindings = require("keybindings")
local gpus = wezterm.gui.enumerate_gpus()

require("on")

return {
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
	font = wezterm.font("Hack Nerd Font"),
	font_size = 16,
	bold_brightens_ansi_colors = false,
	freetype_load_target = "Normal",
	freetype_load_flags = "NO_HINTING|MONOCHROME",
	color_scheme = "Gruvbox dark, medium (base16)",
	tab_max_width = 35,
	initial_rows = 35,
	initial_cols = 120,
	window_background_opacity = 1,
	text_background_opacity = 1,
	window_padding = { left = 5, right = 5, top = 5, bottom = 5 },
	webgpu_preferred_adapter = gpus[1],
	keys = keybindings.create_keybinds(),
	key_tables = keybindings.key_tables,
	mouse_bindings = keybindings.mouse_bindings,
}

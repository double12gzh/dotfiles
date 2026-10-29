local M = {}

local wezterm = require("wezterm")
local utils = require("utils.utils")

local gui = wezterm.gui
local act = wezterm.action

local custom_default_keybinds = {
	-- ctrl + shift + n
	{ key = "N", mods = "CTRL", action = act.SpawnWindow },

	-- Tab {{
	{ key = "h", mods = "ALT", action = act.ActivateTabRelative(-1) },
	{ key = "l", mods = "ALT", action = act.ActivateTabRelative(1) },
	{ key = "n", mods = "ALT", action = wezterm.action.ShowTabNavigator },
	-- Tab }}

	-- Panes {{
	-- Navigating Panes
	{ key = "h", mods = "ALT|SHIFT", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "ALT|SHIFT", action = act.ActivatePaneDirection("Right") },
	{ key = "k", mods = "ALT|SHIFT", action = act.ActivatePaneDirection("Up") },
	{ key = "j", mods = "ALT|SHIFT", action = act.ActivatePaneDirection("Down") },

	-- Close Pane
	{ key = "c", mods = "ALT|SHIFT", action = act.CloseCurrentPane({ confirm = true }) },
	-- Swap Panes
	{
		key = "s",
		mods = "ALT|SHIFT",
		action = act.PaneSelect({ alphabet = "asdfghjkl;", mode = "SwapWithActive" }),
	},
	{ key = "LeftArrow", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "RightArrow", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
	{ key = "UpArrow", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "DownArrow", mods = "ALT|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
	-- Panes }}

	-- Launcher Menu {{
	{ key = "m", mods = "CTRL|ALT|SHIFT", action = act.ShowLauncher },
	{
		key = "p",
		mods = "CTRL|ALT|SHIFT",
		action = act.ShowLauncherArgs({
			flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS|WORKSPACES",
		}),
	},
	-- Launcher Menu }}

	-- Workspace {{
	{ key = "a", mods = "LEADER", action = act.SwitchToWorkspace({ name = "local" }) },
	{ key = "b", mods = "LEADER", action = act.SwitchToWorkspace({ name = "remote" }) },
	{ key = "h", mods = "LEADER", action = act.SwitchWorkspaceRelative(1) },
	{ key = "l", mods = "LEADER", action = act.SwitchWorkspaceRelative(-1) },
	{ key = "n", mods = "LEADER", action = act.SwitchToWorkspace },
	-- Workspace }}

	-- Key table {{
	{ key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
	-- Key table }}
	{ key = "t", mods = "LEADER", action = wezterm.action.ShowTabNavigator },
	{
		key = "c",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
}

local default_keybinds = function()
	local default_keys = {}

	if gui then
		default_keys = gui.default_keys()
	end

	default_keys = utils.append(default_keys, custom_default_keybinds)

	return default_keys
end

local mouse_bindings = function()
	return {
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "NONE",
			action = act({ CompleteSelection = "PrimarySelection" }),
		},
		{
			event = { Down = { streak = 1, button = "Right" } },
			mods = "NONE",
			action = act.PasteFrom("PrimarySelection"),
		},
		{
			event = { Up = { streak = 1, button = "Left" } },
			mods = "CTRL",
			action = "OpenLinkAtMouseCursor",
		},
		-- Scrolling up while holding CTRL increases the font size
		{
			event = { Down = { streak = 1, button = { WheelUp = 1 } } },
			mods = "CTRL",
			action = act.IncreaseFontSize,
		},

		-- Scrolling down while holding CTRL decreases the font size
		{
			event = { Down = { streak = 1, button = { WheelDown = 1 } } },
			mods = "CTRL",
			action = act.DecreaseFontSize,
		},
	}
end

local key_tables = {
	resize_pane = {
		{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },

		{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },

		{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },

		{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },

		-- Cancel the mode by pressing escape
		{ key = "Escape", action = "PopKeyTable" },
	},
}

M.create_keybinds = function()
	return M.default_keybinds
end

M.key_tables = key_tables
M.mouse_bindings = mouse_bindings()
M.default_keybinds = default_keybinds()

return M

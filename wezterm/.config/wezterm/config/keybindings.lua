local M = {}

local wezterm = require("wezterm")
local utils = require("utils.utils")

local gui = wezterm.gui
local act = wezterm.action

wezterm.on("update-right-status", function(window, pane)
	local name = window:active_key_table()
	if name then
		name = "MODE: " .. name
	end
	window:set_left_status(name or "")
end)

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
	local default_keys = nil

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

-- ==========================================================
-- ======================= BACKUP ===========================
-- ==========================================================
--local M = {}
--local wezterm = require("wezterm")
--local act = wezterm.action
--local utils = require("utils.utils")
--
-----------------------------------------------------------------
----- keybinds
-----------------------------------------------------------------
--M.tmux_keybinds = {
--	-- { key = "k", mods = "ALT", action = act({ SpawnTab = "CurrentPaneDomain" }) },
--	-- { key = "j", mods = "ALT", action = act({ CloseCurrentTab = { confirm = true } }) },
--	{ key = "h", mods = "ALT", action = act({ ActivateTabRelative = -1 }) },
--	{ key = "l", mods = "ALT", action = act({ ActivateTabRelative = 1 }) },
--	{ key = "h", mods = "ALT|CTRL", action = act({ MoveTabRelative = -1 }) },
--	{ key = "l", mods = "ALT|CTRL", action = act({ MoveTabRelative = 1 }) },
--	{ key = "k", mods = "ALT|CTRL", action = act.ActivateCopyMode },
--	{
--		key = "k",
--		mods = "ALT|CTRL",
--		action = act.Multiple({ act.CopyMode("ClearSelectionMode"), act.ActivateCopyMode, act.ClearSelection }),
--	},
--	{ key = "j", mods = "ALT|CTRL", action = act({ PasteFrom = "PrimarySelection" }) },
--	-- { key = "1", mods = "CTRL|SHIFT", action = act({ ActivateTab = 0 }) },
--	-- { key = "2", mods = "CTRL|SHIFT", action = act({ ActivateTab = 1 }) },
--	-- { key = "3", mods = "CTRL|SHIFT", action = act({ ActivateTab = 2 }) },
--	-- { key = "4", mods = "CTRL|SHIFT", action = act({ ActivateTab = 3 }) },
--	-- { key = "5", mods = "CTRL|SHIFT", action = act({ ActivateTab = 4 }) },
--	-- { key = "6", mods = "CTRL|SHIFT", action = act({ ActivateTab = 5 }) },
--	-- { key = "7", mods = "CTRL|SHIFT", action = act({ ActivateTab = 6 }) },
--	-- { key = "8", mods = "CTRL|SHIFT", action = act({ ActivateTab = 7 }) },
--	-- { key = "9", mods = "CTRL|SHIFT", action = act({ ActivateTab = 8 }) },
--	{ key = "-", mods = "ALT", action = act({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
--	{ key = "\\", mods = "ALT", action = act({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
--	{ key = "h", mods = "ALT|SHIFT", action = act({ ActivatePaneDirection = "Left" }) },
--	{ key = "l", mods = "ALT|SHIFT", action = act({ ActivatePaneDirection = "Right" }) },
--	{ key = "k", mods = "ALT|SHIFT", action = act({ ActivatePaneDirection = "Up" }) },
--	{ key = "j", mods = "ALT|SHIFT", action = act({ ActivatePaneDirection = "Down" }) },
--	{ key = "h", mods = "ALT|SHIFT|CTRL", action = act({ AdjustPaneSize = { "Left", 1 } }) },
--	{ key = "l", mods = "ALT|SHIFT|CTRL", action = act({ AdjustPaneSize = { "Right", 1 } }) },
--	{ key = "k", mods = "ALT|SHIFT|CTRL", action = act({ AdjustPaneSize = { "Up", 1 } }) },
--	{ key = "j", mods = "ALT|SHIFT|CTRL", action = act({ AdjustPaneSize = { "Down", 1 } }) },
--	{ key = "Enter", mods = "ALT|SHIFT|CTRL", action = "QuickSelect" },
--	{ key = "/", mods = "ALT", action = act.Search("CurrentSelectionOrEmptyString") },
--}
--
--M.default_keybinds = {
--	{
--		key = "n",
--		mods = "CTRL|ALT",
--		action = act({
--			ShowLauncherArgs = { flags = "FUZZY|TABS|LAUNCH_MENU_ITEMS|DOMAINS|KEY_ASSIGNMENTS|WORKSPACES|COMMANDS" },
--		}),
--	},
--	{ key = "c", mods = "CTRL|SHIFT", action = act({ CopyTo = "Clipboard" }) },
--	{ key = "v", mods = "CTRL|SHIFT", action = act({ PasteFrom = "Clipboard" }) },
--	{ key = "Insert", mods = "SHIFT", action = act({ PasteFrom = "PrimarySelection" }) },
--	{ key = "=", mods = "CTRL", action = "ResetFontSize" },
--	{ key = "+", mods = "CTRL", action = "IncreaseFontSize" },
--	{ key = "-", mods = "CTRL", action = "DecreaseFontSize" },
--	{ key = "PageUp", mods = "ALT", action = act({ ScrollByPage = -1 }) },
--	{ key = "PageDown", mods = "ALT", action = act({ ScrollByPage = 1 }) },
--	-- { key = "F5", mods = "CTRL|SHIFT", action = "ReloadConfiguration" },
--	{ key = "z", mods = "ALT|SHIFT", action = act({ EmitEvent = "toggle-tmux-keybinds" }) },
--	{ key = "e", mods = "ALT", action = act({ EmitEvent = "trigger-nvim-with-scrollback" }) },
--	{ key = "w", mods = "ALT", action = act({ CloseCurrentPane = { confirm = false } }) },
--	{
--		key = "r",
--		mods = "ALT",
--		action = act({
--			ActivateKeyTable = {
--				name = "resize_pane",
--				one_shot = false,
--				timeout_milliseconds = 3000,
--				replace_current = false,
--			},
--		}),
--	},
--	{ key = "s", mods = "ALT", action = act.PaneSelect({
--		alphabet = "1234567890",
--	}) },
--	{
--		key = "b",
--		mods = "ALT",
--		action = act.RotatePanes("CounterClockwise"),
--	},
--
--	{ key = "f", mods = "ALT", action = act.RotatePanes("Clockwise") },
--	-- Navigating Panes
--	{ key = "h", mods = "ALT|SHIFT", action = act.ActivatePaneDirection("Left") },
--	{ key = "l", mods = "ALT|SHIFT", action = act.ActivatePaneDirection("Right") },
--	{ key = "k", mods = "ALT|SHIFT", action = act.ActivatePaneDirection("Up") },
--	{ key = "j", mods = "ALT|SHIFT", action = act.ActivatePaneDirection("Down") },
--	-- Close Pane
--	-- { key = "c", mods = "ALT|SHIFT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
--	-- Swap Panes
--	{ key = "i", mods = "ALT|SHIFT", action = act.PaneSelect({ alphabet = "asdfghjkl;", mode = "Activate" }) },
--	{
--		key = "s",
--		mods = "ALT|SHIFT",
--		action = act.PaneSelect({ alphabet = "asdfghjkl;", mode = "SwapWithActive" }),
--	},
--	-- Resize Panes
--	{ key = "LeftArrow", mods = "ALT|SHIFT", action = act({ AdjustPaneSize = { "Left", 5 } }) },
--	{ key = "DownArrow", mods = "ALT|SHIFT", action = act({ AdjustPaneSize = { "Down", 5 } }) },
--	{ key = "UpArrow", mods = "ALT|SHIFT", action = act({ AdjustPaneSize = { "Up", 5 } }) },
--	{ key = "RightArrow", mods = "ALT|SHIFT", action = act({ AdjustPaneSize = { "Right", 5 } }) },
--
--	-- New Tab
--	-- { key = "t", mods = "CTRL|SHIFT", action = act({ SpawnTab = "CurrentPaneDomain" }) },
--	--  New Window
--	-- { key = "n", mods = "CTRL|SHIFT", action = act.SpawnWindow },
--	-- Swap Tabs
--	-- { key = "h", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
--	-- { key = "l", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
--}
--
--function M.create_keybinds()
--	return utils.merge_lists(M.default_keybinds, M.tmux_keybinds)
--end
--
--M.key_tables = {
--	resize_pane = {
--		{ key = "LeftArrow", action = act({ AdjustPaneSize = { "Left", 1 } }) },
--		{ key = "h", action = act({ AdjustPaneSize = { "Left", 1 } }) },
--		{ key = "RightArrow", action = act({ AdjustPaneSize = { "Right", 1 } }) },
--		{ key = "l", action = act({ AdjustPaneSize = { "Right", 1 } }) },
--		{ key = "UpArrow", action = act({ AdjustPaneSize = { "Up", 1 } }) },
--		{ key = "k", action = act({ AdjustPaneSize = { "Up", 1 } }) },
--		{ key = "DownArrow", action = act({ AdjustPaneSize = { "Down", 1 } }) },
--		{ key = "j", action = act({ AdjustPaneSize = { "Down", 1 } }) },
--		-- Cancel the mode by pressing escape
--		{ key = "Escape", action = "PopKeyTable" },
--	},
--	copy_mode = {
--		{
--			key = "Escape",
--			mods = "NONE",
--			action = act.Multiple({
--				act.ClearSelection,
--				act.CopyMode("ClearPattern"),
--				act.CopyMode("Close"),
--			}),
--		},
--		{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
--		-- move cursor
--		{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
--		{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
--		{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
--		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
--		{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
--		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
--		{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
--		{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
--		-- move word
--		{ key = "RightArrow", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
--		{ key = "f", mods = "ALT", action = act.CopyMode("MoveForwardWord") },
--		{ key = "\t", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
--		{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
--		{ key = "LeftArrow", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
--		{ key = "b", mods = "ALT", action = act.CopyMode("MoveBackwardWord") },
--		{ key = "\t", mods = "SHIFT", action = act.CopyMode("MoveBackwardWord") },
--		{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
--		{
--			key = "e",
--			mods = "NONE",
--			action = act({
--				Multiple = {
--					act.CopyMode("MoveRight"),
--					act.CopyMode("MoveForwardWord"),
--					act.CopyMode("MoveLeft"),
--				},
--			}),
--		},
--		-- move start/end
--		{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
--		{ key = "\n", mods = "NONE", action = act.CopyMode("MoveToStartOfNextLine") },
--		{ key = "$", mods = "SHIFT", action = act.CopyMode("MoveToEndOfLineContent") },
--		{ key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
--		{ key = "e", mods = "CTRL", action = act.CopyMode("MoveToEndOfLineContent") },
--		{ key = "m", mods = "ALT", action = act.CopyMode("MoveToStartOfLineContent") },
--		{ key = "^", mods = "SHIFT", action = act.CopyMode("MoveToStartOfLineContent") },
--		{ key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
--		{ key = "a", mods = "CTRL", action = act.CopyMode("MoveToStartOfLineContent") },
--		-- select
--		{ key = " ", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
--		{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
--		{
--			key = "v",
--			mods = "SHIFT",
--			action = act({
--				Multiple = {
--					act.CopyMode("MoveToStartOfLineContent"),
--					act.CopyMode({ SetSelectionMode = "Cell" }),
--					act.CopyMode("MoveToEndOfLineContent"),
--				},
--			}),
--		},
--		-- copy
--		{
--			key = "y",
--			mods = "NONE",
--			action = act({
--				Multiple = {
--					act({ CopyTo = "ClipboardAndPrimarySelection" }),
--					act.CopyMode("Close"),
--				},
--			}),
--		},
--		{
--			key = "y",
--			mods = "SHIFT",
--			action = act({
--				Multiple = {
--					act.CopyMode({ SetSelectionMode = "Cell" }),
--					act.CopyMode("MoveToEndOfLineContent"),
--					act({ CopyTo = "ClipboardAndPrimarySelection" }),
--					act.CopyMode("Close"),
--				},
--			}),
--		},
--		-- scroll
--		{ key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
--		{ key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
--		{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
--		{ key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
--		{ key = "H", mods = "SHIFT", action = act.CopyMode("MoveToViewportTop") },
--		{ key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
--		{ key = "M", mods = "SHIFT", action = act.CopyMode("MoveToViewportMiddle") },
--		{ key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
--		{ key = "L", mods = "SHIFT", action = act.CopyMode("MoveToViewportBottom") },
--		{ key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
--		{ key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
--		{ key = "O", mods = "SHIFT", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
--		{ key = "PageUp", mods = "NONE", action = act.CopyMode("PageUp") },
--		{ key = "PageDown", mods = "NONE", action = act.CopyMode("PageDown") },
--		{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
--		{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
--		{
--			key = "Enter",
--			mods = "NONE",
--			action = act.CopyMode("ClearSelectionMode"),
--		},
--		-- search
--
--		{ key = "/", mods = "NONE", action = act.Search("CurrentSelectionOrEmptyString") },
--		{
--			key = "n",
--			mods = "NONE",
--			action = act.Multiple({
--				act.CopyMode("NextMatch"),
--				act.CopyMode("ClearSelectionMode"),
--			}),
--		},
--		{
--			key = "N",
--			mods = "SHIFT",
--			action = act.Multiple({
--				act.CopyMode("PriorMatch"),
--				act.CopyMode("ClearSelectionMode"),
--			}),
--		},
--	},
--	search_mode = {
--		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
--		{
--			key = "Enter",
--			mods = "NONE",
--			action = act.Multiple({
--				act.CopyMode("ClearSelectionMode"),
--				act.ActivateCopyMode,
--			}),
--		},
--		{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
--		{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
--		{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
--		{ key = "/", mods = "NONE", action = act.CopyMode("ClearPattern") },
--		{ key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
--	},
--}
--
--M.mouse_bindings = {
--	{
--		event = { Up = { streak = 1, button = "Left" } },
--		mods = "NONE",
--		action = act({ CompleteSelection = "PrimarySelection" }),
--	},
--	--	{
--	--		event = { Up = { streak = 1, button = "Right" } },
--	--		mods = "NONE",
--	--		action = act({ CompleteSelection = "Clipboard" }),
--	--	},
--	{
--		event = { Down = { streak = 1, button = "Right" } },
--		mods = "NONE",
--		action = act.PasteFrom("PrimarySelection"),
--	},
--	{
--		event = { Up = { streak = 1, button = "Left" } },
--		mods = "CTRL",
--		action = "OpenLinkAtMouseCursor",
--	},
--	-- Scrolling up while holding CTRL increases the font size
--	{
--		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
--		mods = "CTRL",
--		action = act.IncreaseFontSize,
--	},
--
--	-- Scrolling down while holding CTRL decreases the font size
--	{
--		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
--		mods = "CTRL",
--		action = act.DecreaseFontSize,
--	},
--}
--
--return M

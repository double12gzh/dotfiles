local wezterm = require("wezterm")

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local str = tab.active_pane.title
	local index = tab.tab_index + 1
	if str == "vim" then
		str = "nvim"
	else
		str = string.gsub(str, "(.*[/\\])(.*)", "%2")
	end

	local title = " " .. index .. ":" .. str .. " "

	if tab.is_active then
		return { { Background = { Color = "#f7bb3b" } }, { Foreground = { Color = "black" } }, { Text = title } }
	end

	return { { Text = title } }
end)

wezterm.on('update-right-status', function(window, pane)
        -- "Wed Mar 3 08:14"
        local date = wezterm.strftime '%a %b %-d %H:%M '

        local bat = ''
        for _, b in ipairs(wezterm.battery_info()) do
          bat = '🔋 ' .. string.format('%.0f%%', b.state_of_charge * 100)
        end

        window:set_right_status(wezterm.format {
          { Text = bat .. '   ' .. date },
        })
end)

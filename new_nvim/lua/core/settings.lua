local settings = {}
local home = os.getenv("HOME")

settings["use_ssh"] = false
settings["format_disabled_dirs"] = {
	-- home .. "/format_disabled_dir_under_home",
	home .. "/.config/alacritty",
}

return settings

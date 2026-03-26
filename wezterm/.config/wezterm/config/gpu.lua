local wezterm = require("wezterm")
local config = {}

-- Rendering options
config.front_end = "WebGpu"
config.max_fps = 120

-- Font settings
config.font = wezterm.font("Hack Nerd Font Mono")  -- use the font variable
config.freetype_load_flags = "NO_HINTING"          -- disable hinting

-- Platform-specific GPU preferences (your earlier snippet)
if wezterm.target_triple:find("windows") then
    config.webgpu_power_preference = "HighPerformance"
    config.webgpu_preferred_adapter = {
        backend = "Vulkan",
        device = 7171,
        device_type = "DiscreteGpu",
        driver = "NVIDIA",
        driver_info = "516.94",
        name = "NVIDIA GeForce GTX 1060 6GB",
        vendor = 4318,
    }
end

-- (Remove any line that says prefer_egl = true)

return config
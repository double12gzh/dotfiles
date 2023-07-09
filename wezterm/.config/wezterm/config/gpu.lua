local M = {}

-- enumerate_gpus has bug: https://github.com/gfx-rs/wgpu/issues/3813
-- after the bug is fixed, uncomment the following codes and remove code
-- l26 ~ l37
--
-- local has_vulkan = function()
-- 	local gpus = wezterm.gui.enumerate_gpus()
-- 	for _, gpu in ipairs(gpus) do
-- 		if gpu.backend == 'Vulkan' and gpu.device_type == 'DiscreteGpu' then
-- 			return gpu
-- 		end
-- 	end

-- 	return false
-- end

-- local vulkan = has_vulkan()
-- if vulkan then
-- 	M.webgpu_power_preference = "HighPerformance"
-- 	M.webgpu_preferred_adapter = vulkan
-- 	M.front_end = 'WebGpu'
-- 	M.max_fps = 144
-- end

M.webgpu_power_preference = "HighPerformance"
M.max_fps = 144
M.front_end = "WebGpu"
M.webgpu_preferred_adapter = {
	backend = "Vulkan",
	device = 7171,
	device_type = "DiscreteGpu",
	driver = "NVIDIA",
	driver_info = "516.94",
	name = "NVIDIA GeForce GTX 1060 6GB",
	vendor = 4318,
}

return M

local M = {}

function M.merge_lists(t1, t2)
	local result = {}
	for _, v in pairs(t1) do
		table.insert(result, v)
	end
	for _, v in pairs(t2) do
		table.insert(result, v)
	end
	return result
end

function M.append(dest, src)
	for _, v in pairs(src) do
		table.insert(dest, v)
	end

	return dest
end

return M

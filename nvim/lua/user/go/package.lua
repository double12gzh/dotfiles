local util = require 'user.utils.util'
local M = {}

M.pkg_from_path = function(pkg, bufnr)
  local cmd = { 'go', 'list' }
  if pkg ~= nil then
    table.insert(cmd, pkg)
  end
  return util.exec_in_path(cmd, bufnr)
end

return M

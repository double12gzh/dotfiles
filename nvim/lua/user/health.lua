local health = vim.health or require 'health'
local M = {}

-- {{{
local check_executable = function(bin, name, advice)
  if vim.fn.executable(bin) == 0 then
    health.report_error(string.format('Please install %s, %s', name, advice))
  else
    health.report_ok(string.format('%s is installed', name))
  end
end
-- }}}

M.check = function()
  health.report_start 'Checking nvim configuration requirements'
  check_executable('yarn', 'yarn', 'Refer to https://classic.yarnpkg.com/en/docs/install')
  check_executable('rg', 'ripgrep', 'Refer to https://github.com/BurntSushi/ripgrep#installation')
end

return M

local M = {}

local log = require "telescope.log"
local utils = require'telescope._extensions.repo.utils'

-- Prepare locate command and change opts accordingly
M.prepare_command = function(opts)
	opts = opts or {}
  opts.bin = opts.bin or utils.find_locate_binary()
  if opts.bin == "" then
    error "Please install locate (or one of its alternatives)"
  end
  opts.cwd = vim.env.HOME

  local repo_pattern = opts.pattern or [[/\.git$]] -- We match on the whole path
  local locate_opts = opts.locate_opts or {}
  local locate_command = vim.tbl_flatten{opts.bin, locate_opts, {'-r', repo_pattern}}
  log.trace("locate_command: "..vim.inspect(locate_command))

  return locate_command
end

return M

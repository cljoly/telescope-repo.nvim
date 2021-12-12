local M = {}

local utils = require'telescope._extensions.repo.utils'

-- Prepare fd command and change opts accordingly
M.prepare_command = function(opts)
  opts = opts or {}
  opts.bin = opts.bin or utils.find_fd_binary()
  if opts.bin == "" then
    error("fd not found, is fd installed?")
  end
  opts.cwd = vim.env.HOME

  local fd_command = {opts.bin}
  local repo_pattern = opts.pattern or [[^\.git$]]

  -- Don’t filter only on directories with fd as git worktrees actually have a
  -- .git file in them.
  local find_repo_opts = {'--hidden', '--case-sensitive', '--absolute-path'}
  local find_user_opts = opts.fd_opts or {}
  local find_exec_opts = {'--exec', 'echo', [[{//}]], ';'}
  local find_pattern_opts = {repo_pattern}

  table.insert(fd_command, find_repo_opts)
  table.insert(fd_command, find_user_opts)
  table.insert(fd_command, find_exec_opts)
  table.insert(fd_command, find_pattern_opts)
  fd_command = vim.tbl_flatten(fd_command)

  return fd_command
end

return M

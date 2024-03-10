local M = {}

local log = require("telescope.log")
local utils = require("telescope._extensions.repo.utils")

-- Prepare fd command and change opts accordingly
M.prepare_command = function(opts)
    opts = opts or {}
    opts.bin = opts.bin or utils.find_fd_binary()
    if not opts.bin then
        error("fd not found, is fd installed?")
    end
    opts.cwd = vim.env.HOME

    local fd_command = { opts.bin }
    local repo_pattern = opts.pattern or [[^\.git$]]

    -- Don’t filter only on directories with fd as git worktrees actually have a
    -- .git file in them.
    local find_repo_opts = { "--hidden", "--no-ignore-vcs", "--case-sensitive", "--absolute-path" }
    local find_user_opts = opts.fd_opts or {}
    local find_exec_opts = { "--exec", "echo", [[{//}]], ";" }

    -- Expand '~'
    local search_dirs = {}
    for i, d in ipairs(opts.search_dirs or {}) do
        search_dirs[i] = vim.fn.expand(d)
    end

    table.insert(fd_command, find_repo_opts)
    table.insert(fd_command, find_user_opts)
    table.insert(fd_command, find_exec_opts)
    table.insert(fd_command, repo_pattern)
    table.insert(fd_command, search_dirs)
    fd_command = vim.tbl_flatten(fd_command)
    log.trace("fd command: " .. vim.inspect(fd_command))

    return fd_command
end

--[[
TODO “Smart” list that
  1. reads the content of a cache file stored in vim.fn.stdpath("data") and prints it to stdout
  2. “on the same stdout”, runs fd piped into tee to udpate the cache
  3. awk is used to deduplicate. Stale entries are shown only once
  4. mv the new cache to replace the old cache
```fish
begin cat /tmp/cache; fd | tee /tmp/cache; end | awk 'seen[$0]++ == 0'
```
drawbacks:
* increased memory and CPU consumption due to the deduplication
--]]

return M

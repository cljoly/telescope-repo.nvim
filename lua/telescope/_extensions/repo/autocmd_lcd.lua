local M = {}

local autocmd_group_name = "telescope_repo_lcd"

-- Define autocmd to change the folder of the current file (with lcd).
-- This function makes sure that no similar autocmd exists for a particular git repository.
-- It handles the case of nested git directory by going to the deepest git repository an autocmd is called for.
-- @return true if an autocmd was successfully installed
M.autocmd_lcd = function(path)
    if not vim.fn.has('nvim-0.7.0') then
        return false
    end

    local autocmd_opts = {
        group = autocmd_group_name,
        event = { "BufNewFile", "BufRead" },
        pattern = { path .. "/*" }
    }
    local existing_autocommand = vim.api.nvim_get_autocmds(autocmd_opts)
    if #existing_autocommand >= 0 then
        return true
    end

    vim.api.nvim_create_autocmd(autocmd_opts.event, vim.tbl_extend("force", autocmd_opts, { callback = function()
        local cwd = vim.fn.getcwd()
        if #cwd > #path and cwd:sub(1, #path) == path then
            -- We are already deeper in the hierarchy, don’t move up
            return
        end
        vim.cmd("lcd " .. path)
    end,
    desc = "lcd (if not deeper already) to " .. path }))
end

return M

local Path = require("plenary.path")

local M = {}

M.active = false

-- List of absolute paths to projects opened with the extension
local project_paths = {}

-- Add a project path so that the autocmd will lcd to it if a file in that path is opened
function M.add_project(path)
    local abs_path = Path:new(path)
    abs_path = abs_path:absolute()
    project_paths[abs_path] = true
end

-- Find the best suited project path. Can be passed a file
local function find_project(path_or_file)
    local buf_path = Path:new(path_or_file)
    local abs_buf_path = buf_path:absolute()
    while not (project_paths[abs_buf_path] or abs_buf_path == "/") do
        buf_path = buf_path:parent()
        abs_buf_path = buf_path:absolute()
    end
    if abs_buf_path ~= "/" then
        return abs_buf_path
    end
    return nil
end

-- Define autocmd to change the folder of the current file (with lcd).
function M.setup()
    M.active = true
    -- Deactivate autochdir
    vim.opt.autochdir = false
    -- Detect an active vim-rooter and use it only as a fallback
    if vim.g.loaded_rooter == 1 then
        vim.g.rooter_manual_only = 1
        vim.g.rooter_cd_cmd = "lcd"
    end

    -- Ensure we create only one autocmd, even if the function is called multiple times
    local autocmd_group = vim.api.nvim_create_augroup("telescope_repo_lcd", { clear = true })

    -- Events inspired by vim-rooter
    vim.api.nvim_create_autocmd({ "BufNewFile", "BufEnter", "BufReadPost" }, {
        callback = function()
            local path_or_file = vim.fn.expand("%")
            local project_path = find_project(path_or_file)
            if project_path then
                vim.cmd.lcd(project_path)
            elseif vim.g.loaded_rooter == 1 then
                vim.cmd.Rooter()
            end
        end,
        group = autocmd_group,
        desc = "lcd to the deepest project directory",
    })
end

return M

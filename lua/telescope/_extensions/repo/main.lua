local os_home = vim.loop.os_homedir()
-- External dependancies
local actions = require("telescope.actions")
local actions_set = require("telescope.actions.set")
local actions_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local from_entry = require("telescope.from_entry")
local log = require("telescope.log")
local pickers = require("telescope.pickers")
local previewers = require("telescope.previewers")
local t_utils = require("telescope.utils")
local Path = require("plenary.path")

-- Other modules in this plugin
local autocmd_lcd = require("telescope._extensions.repo.autocmd_lcd")
local utils = require("telescope._extensions.repo.utils")
local list = require("telescope._extensions.repo.list")
local cached_list = require("telescope._extensions.repo.cached_list")
local r_config = require("telescope._extensions.repo.config")

local M = {}

local function search_markdown_readme(dir)
    for _, name in pairs({
        "README",
        "README.md",
        "README.markdown",
        "README.mkd",
    }) do
        local file = dir / name
        if file:is_file() then
            return file
        end
    end
    return nil
end

local function search_generic_readme(dir)
    local doc_path = Path:new(dir, "README.*")
    local maybe_doc = vim.split(vim.fn.glob(doc_path.filename), "\n")
    for _, filepath in pairs(maybe_doc) do
        local file = Path:new(filepath)
        if file:is_file() then
            return file
        end
    end
    return nil
end

local function search_doc(dir)
    local doc_path = Path:new(dir, "doc", "**", "*.txt")
    local maybe_doc = vim.split(vim.fn.glob(doc_path.filename), "\n")
    for _, filepath in pairs(maybe_doc) do
        local file = Path:new(filepath)
        if file:is_file() then
            return file
        end
    end
    return nil
end

-- Was gen_from_ghq in telescope-ghq.nvim
local function gen_from_fd(opts)
    local displayer = entry_display.create({
        items = { {} },
    })

    -- This prevents opts.cwd from changing later when it’s called in the
    -- display function
    local cwd = opts.cwd
    local function make_display(entry)
        if not cwd then cwd = opts.cwd end
        local dir = (function(path)
            if path == Path.path.root() then
                return path
            end

            local p = Path:new(path)
            if opts.tail_path then
                local parts = p:_split()
                return parts[#parts]
            end

            if opts.shorten_path then
                return p:shorten()
            end

            if vim.startswith(path, cwd) and path ~= cwd then
                return Path:new(p):make_relative(cwd)
            end

            if vim.startswith(path, os_home) then
                return (Path:new("~") / p:make_relative(os_home)).filename
            end
            return path
        end)(entry.path)

        return displayer({ dir })
    end

    return function(line)
        return {
            value = line,
            ordinal = line,
            path = line,
            display = make_display,
        }
    end
end

-- Wrap entries to remove the part we used to detect the VCS. For instance, for git:
-- - we get entries like “/home/me/repo/.git”
-- - we want to send entries like “/home/me/repo”
local function gen_from_locate_wrapper(opts)
    log.trace("Called gen_from_locate_wrapper")
    -- TODO Make this a wrapper over any function, not just gen_from_fd
    -- TODO It’s not great for performance to parse paths in the whole list like this
    return function(line_with_dotgit)
        log.trace("line_with_dotgit " .. line_with_dotgit)
        local line = Path:new(line_with_dotgit):parent().filename
        return gen_from_fd(opts)(line)
    end
end

local function project_files(opts)
    local ok = pcall(require("telescope.builtin").git_files, opts)
    if not ok then
        require("telescope.builtin").find_files(opts)
    end
end

local function project_live_grep(opts)
    require("telescope.builtin").live_grep(opts)
end

local function call_picker(list_opts, command, prompt_title_supplement, user_opts)
    if list_opts == nil then
        error([[
        Incorrect call to call_picker, list_opts should be specified to pass relevant options to the first picker]])
    end
    if user_opts == nil then
        error([[
        Incorrect call to call_picker, user_opts should be specified to pass relevant options to the second picker]])
    end

    local prompt_title = "Git repositories"
    if prompt_title_supplement ~= nil then
        prompt_title = prompt_title .. prompt_title_supplement
    end
    pickers
        .new(list_opts, {
            prompt_title = prompt_title,
            finder = finders.new_oneshot_job(command, list_opts),
            previewer = previewers.new_termopen_previewer({
                get_command = function(entry)
                    local dir = Path:new(from_entry.path(entry))
                    local doc = search_markdown_readme(dir)
                    if doc then
                        return utils.find_markdown_previewer_for_document(doc.filename)
                    end
                    doc = search_generic_readme(dir)
                    if not doc then
                        -- TODO: doc may be previewed in a plain text. Can I use syntax highlight?
                        doc = search_doc(dir)
                    end
                    if not doc then
                        return { "echo", "" }
                    end
                    return utils.find_generic_previewer_for_document(doc.filename)
                end,
            }),
            sorter = conf.file_sorter(list_opts),
            attach_mappings = function(prompt_bufnr)
                actions_set.select:replace(function(_, type)
                    local entry = actions_state.get_selected_entry()
                    local dir = from_entry.path(entry)
                    if autocmd_lcd.active and type ~= "" then
                        autocmd_lcd.add_project(dir)
                    end

                    if type == "default" then
                        actions._close(prompt_bufnr, false)
                        vim.schedule(function()
                            project_files(vim.tbl_extend("force", user_opts, { cwd = dir }))
                        end)
                    end
                    if type == "vertical" then
                        actions._close(prompt_bufnr, false)
                        vim.schedule(function()
                            project_live_grep(vim.tbl_extend("force", list_opts, { cwd = dir }))
                        end)
                        return
                    end
                    if type == "tab" then
                        vim.cmd("tabe " .. dir)
                        vim.cmd("tcd " .. dir)
                        project_files(vim.tbl_extend("force", list_opts, { cwd = dir }))
                        return
                    end
                end)
                return true
            end,
        })
        :find()
end

-- List of repos built using locate (or variants)
M.cached_list = function(opts)
    local common_opts = opts or {}
    local list_opts = vim.tbl_deep_extend("force", r_config.values.cached_list or {}, common_opts)
    list_opts.entry_maker = t_utils.get_lazy_default(list_opts.entry_maker, gen_from_locate_wrapper, list_opts)
    local locate_command = cached_list.prepare_command(list_opts)

    call_picker(list_opts, locate_command, " (cached)", common_opts)
end

-- Always up to date list of repos built using fd
M.list = function(opts)
    local common_opts = opts or {}
    local list_opts = vim.tbl_deep_extend("force", r_config.values.list or {}, common_opts)
    list_opts.entry_maker = t_utils.get_lazy_default(list_opts.entry_maker, gen_from_fd, list_opts)
    local fd_command = list.prepare_command(list_opts)

    call_picker(list_opts, fd_command, " (built on the fly)", common_opts)
end

return M

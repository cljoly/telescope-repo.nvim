local M = {}

local utils = require("telescope._extensions.repo.utils")
local list = require("telescope._extensions.repo.list")
local cached_list = require("telescope._extensions.repo.cached_list")

-- TODO Keep only vim.health once nvim 0.8 is required
local health = vim.health or require("health")

local Job = require("plenary.job")
local max_repo = 2

local function get_version(binary)
    local handle = io.popen(binary .. " --version")
    local version = handle:read("*a")
    handle:close()
    return version
end

local function find_repos(_opts, cmd_with_args, telescope_cmd)
    local j = Job:new({
        command = cmd_with_args[1],
        args = vim.list_slice(cmd_with_args, 2, #cmd_with_args),
    })
    j:sync()

    if j.code == 0 then
        local some_repos = vim.list_slice(j:result(), 1, max_repo)
        health.report_info("Repos found for `" .. telescope_cmd .. "`:\n" .. table.concat(some_repos, ", ") .. "...")
    else
        health.report_error(
            "`"
                .. telescope_cmd
                .. "` was unsuccessful. Exit code: "
                .. tostring(j.code)
                .. "\n"
                .. j.command
                .. " "
                .. table.concat(j.args, " ")
                .. "\n "
                .. table.concat(j:result(), "\n")
                .. table.concat(j:stderr_result(), "\n")
        )
    end
end

local function check_list_cmd()
    local fd_bin = utils.find_fd_binary()
    if fd_bin then
        health.report_ok("fd: found `" .. fd_bin .. "`\n" .. get_version(fd_bin))

        local opts = {}
        local command_with_args = list.prepare_command(opts)
        find_repos(opts, command_with_args, ":Telescope repo list")
    else
        health.report_error("`list` will not function without [fd](https://github.com/sharkdp/fd)")
    end
end

local function check_cached_list_cmd()
    local locate_bin = utils.find_locate_binary()
    if locate_bin then
        health.report_ok("locate: found `" .. locate_bin .. "`\n" .. get_version(locate_bin))

        local opts = {}

        local command_with_args = cached_list.prepare_command(opts)

        -- lolcate doesn't have limit functionality.
        if locate_bin == "lolcate" then
            command_with_args = { locate_bin, "--info" }
        else
            command_with_args = vim.tbl_flatten({ command_with_args, { "-l", tostring(max_repo) } })
        end

        find_repos(opts, command_with_args, ":Telescope repo cached_list")
    else
        health.report_error("`cached_list` will not function without locate")
    end
end

local function check_previewer_md()
    local markdown_bin = utils.find_markdown_previewer_for_document("test_doc.md")
    if not markdown_bin then
        health.report_error("No markdown previewer found, the extension will not work properly")
        return
    end
    health.report_ok("Will use `" .. markdown_bin[1] .. "` to preview markdown READMEs")

    local first = utils._markdown_previewer[1][1]
    if markdown_bin[1] ~= first then
        health.report_warn("Install `" .. first .. "` for a better preview of markdown files")
    end
end

local function check_previewer_generic()
    local generic_bin = utils.find_generic_previewer_for_document("test_doc")
    if not generic_bin then
        health.report_error("No markdown previewer found, the extension will not work properly")
        return
    end
    health.report_ok("Will use `" .. generic_bin[1] .. "` to preview non-markdown READMEs")

    local first = utils._generic_previewer[1][1]
    if generic_bin[1] ~= first then
        health.report_warn("Install `" .. first .. "` for a better preview of other files")
    end
end

M.check = function()
    -- Ordered from fastest to slowest
    check_previewer_generic()
    check_previewer_md()
    check_cached_list_cmd()
    check_list_cmd()
end

return M

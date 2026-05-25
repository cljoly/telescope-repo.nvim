local M = {}

M.values = {}

-- See https://luals.github.io/wiki/annotations/ for type anotation reference
-- Some global type aliases and classes are defined in this file by convention

---@alias repoList string[]
---@alias command string[]

---Global options used by the plugin.
---@class (exact) GlobalOpts
---@field list? ListOpts Opts for the list subcommand
---@field cached_list? CachedListOpts Opts for the list subcommand
---@field settings? Settings

---Global settings
---@class (exact) Settings
---@field auto_lcd? boolean Whether the lcd command is used to change directory
---as files are opened

---Common fields to all subcommands
---@class (exact) CommonSubcommandOpts
---@field bin? string File path for the binary `fd`
---@field pattern? string Pattern of the SCM database folder
---@field cwd? string Transform absolute path into relative paths relative to cwd
---@field tail_path? boolean Show only the base name of the path
---@field shorten_path? boolean Call shorten_path on each path

---@class (exact) ListOpts: CommonSubcommandOpts
---@field fd_opts? string[] Options for the fd command
---@field fd_exec_opts? string[] Options to run results through a shell commands
---(accommodate OS differences)
---@field search_dirs? string[] Directories to search in

---@class (exact) CachedListOpts: CommonSubcommandOpts
---@field locate_opts? string[] Options for the locate command

---Setup function called by telescope
---@param opts GlobalOpts
function M.setup(opts)
    M.values = opts or {}
    if M.values.settings and M.values.settings.auto_lcd then
        require("telescope._extensions.repo.autocmd_lcd").setup()
    end
end

return M

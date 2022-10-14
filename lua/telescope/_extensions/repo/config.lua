local M = {}

M.values = {}

function M.setup(opts)
    M.values = opts or {}
    if M.values.settings and M.values.settings.auto_lcd then
        require("telescope._extensions.repo.autocmd_lcd").setup()
    end
end

return M

local M = {}

M.values = {}

local default_config = {
    settings = {
        auto_lcd = true,
    },
}

function M.setup(opts)
    M.values = vim.tbl_extend("keep", opts, default_config)
    if M.values.settings.auto_lcd then
        require("telescope._extensions.repo.autocmd_lcd").setup()
    end
end

return M

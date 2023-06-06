local M = {}

M.values = {}

local default_config = {
    settings = {
        auto_lcd = {
            enabled = true,
            global_cd_for_first_project = true,
            vimrooter_integration = true,
        },
    },
}

function M.setup(opts)
    M.values = vim.tbl_extend("keep", opts, default_config)
    if M.values.settings.auto_lcd.enabled then
        require("telescope._extensions.repo.autocmd_lcd").setup(M.values.settings.auto_lcd)
    end
end

return M

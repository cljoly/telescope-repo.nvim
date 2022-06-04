local main = require("telescope._extensions.repo.main")
local r_config = require("telescope._extensions.repo.config")
local health = require("telescope._extensions.repo.health")

local fallback_error = { "Falling back to `:Telescope repo list`, but this behavior may change in the future" }

return require("telescope").register_extension({
    health = health.check,
    setup = r_config.setup,
    exports = {
        list = main.list,
        cached_list = main.cached_list,
        -- Default command, for now, may change
        repo = function(opts)
            vim.api.nvim_echo({ fallback_error }, true, {})
            main.list(opts)
        end,
    },
})

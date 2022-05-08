local main = require("telescope._extensions.repo.main")

local fallback_error = { "Falling back to `:Telescope repo list`, but this behavior may change in the future" }

return require("telescope").register_extension({
    health = function()
        require("telescope._extensions.repo.health").check()
    end,
    setup = function(opts)
        require("telescope._extensions.repo.config").setup(opts)
    end,
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

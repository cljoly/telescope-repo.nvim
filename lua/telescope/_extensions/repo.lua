local main = require'telescope._extensions.repo.main'
local health = require'telescope._extensions.repo.health'

return require'telescope'.register_extension{
  health = health.check,
  exports = {
    list = main.list,
    cached_list = main.cached_list,
    -- Default command, for now, may change
    repo = function (opts)
      vim.api.nvim_echo({{"Falling back to `:Telescope repo list`, but this behavior may change in the future"}}, true, {})
      main.list(opts)
    end,
  },
}

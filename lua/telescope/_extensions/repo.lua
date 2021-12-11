local main = require'telescope._extensions.repo.main'
local health = require'telescope._extensions.repo.health'

return require'telescope'.register_extension{
  health = health.check,
  exports = {
    list = main.list,
    cached_list = main.cached_list,
  },
}

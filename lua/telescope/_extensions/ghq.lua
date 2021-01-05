local builtin = require'telescope.builtin'
local ghq_builtin = require'telescope._extensions.ghq_builtin'

return require'telescope'.register_extension{
  setup = function()
    builtin.ghq_list = ghq_builtin.list
  end,
}

local ghq_builtin = require'telescope._extensions.ghq_builtin'

return require'telescope'.register_extension{
  exports = {
    list = ghq_builtin.list
  },
}

local conf = require'telescope.config'.values
local finders = require'telescope.finders'
local pickers = require'telescope.pickers'
local previewers = require'telescope.previewers'

local M = {}

M.list = function(opts)
  opts = opts or {}
  local cmd = vim.tbl_flatten{'ghq', 'list', '--full-path'}
  pickers.new(opts, {
    prompt_title = 'Repositories managed by ghq',
    finder = finders.new_oneshot_job(
      cmd,
      opts
    ),
    previewer = previewers.new_termopen_previewer{
      get_command = function(entry)
        -- TODO: deal with another README
        local readme
        for _, name in pairs{'README', 'README.md'} do
          local path = entry.value..'/'..name
          local file_found = io.open(path)
          if file_found then
            io.close(file_found)
            readme = path
            break
          end
        end
        if readme then
          return {'bat', readme}
        end
        return {'echo', ''}
      end,
      sorter = conf.file_sorter(opts),
    },
  }):find()
end

return M

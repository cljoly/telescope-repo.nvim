local actions = require'telescope.actions'
local conf = require'telescope.config'.values
local finders = require'telescope.finders'
local from_entry = require'telescope.from_entry'
local pickers = require'telescope.pickers'
local previewers = require'telescope.previewers'

local M = {}

M.list = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = 'Repositories managed by ghq',
    finder = finders.new_oneshot_job(
      {'ghq', 'list', '--full-path'},
      opts
    ),
    previewer = previewers.new_termopen_previewer{
      get_command = function(entry)
        -- TODO: deal with other README's
        local readme
        for _, name in pairs{'README', 'README.md', 'README.markdown'} do
          local path = entry.value..'/'..name
          local file_found = io.open(path)
          if file_found then
            io.close(file_found)
            readme = path
            break
          end
        end
        if readme then
          if vim.fn.executable'glow' == 1 then
            return {'glow', readme}
          elseif vim.fn.executable'bat' == 1 then
            return {'bat', '--style', 'header,grid', readme}
          end
          return {'cat', readme}
        end
        return {'echo', ''}
      end,
    },
    sorter = conf.file_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions._goto_file_selection:replace(function(_, cmd)
        local entry = actions.get_selected_entry()
        actions.close(prompt_bufnr)
        local path = from_entry.path(entry)
        if cmd == 'edit' then
          require'telescope.builtin'.git_files{cwd = path}
        elseif cmd == 'new' then
          vim.cmd('cd '..path)
          print('chdir to '..path)
        elseif cmd == 'vnew' then
          vim.cmd('lcd '..path)
          print('lchdir to '..path)
        end
      end)
      return true
    end,
  }):find()
end

return M

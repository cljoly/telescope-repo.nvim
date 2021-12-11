local M = {}

-- Find the first executable in binaries that can be found in the PATH
local function find_binary(binaries)
  for _, binary in ipairs(binaries) do
    if vim.fn.executable(binary) == 1 then
      return binary
    end
  end
  return ""
end

-- Find under what name fd is installed.
M.find_fd_binary = function()
  return find_binary({ "fdfind", "fd" })
end

-- Find under what name locate is installed, prioritizing more “modern” locate
M.find_locate_binary = function()
  return find_binary({ "plocate", "glocate", "locate" })
end

return M

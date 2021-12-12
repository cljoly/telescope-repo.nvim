local M = {}

-- Find the first executable in binaries that can be found in the PATH
local function find_binary(binaries)
	for _, binary in ipairs(binaries) do
		if type(binary) == "string" and vim.fn.executable(binary) == 1 then
			return binary
		elseif type(binary) == "table" and vim.fn.executable(binary[1]) == 1 then
			return vim.deepcopy(binary)
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

M._generic_previewer = { { "bat", "--style", "header,grid" }, { "cat" } }

M.find_generic_previewer_for_document = function(doc)
	local l = find_binary(M._generic_previewer)
	table.insert(l, doc)
	return l
end

M._markdown_previewer = { { "glow", "-p"} }
vim.list_extend(M._markdown_previewer, M._generic_previewer)

M.find_markdown_previewer_for_document = function(doc)
	local l = find_binary(M._markdown_previewer)
	table.insert(l, doc)
	return l
end

return M

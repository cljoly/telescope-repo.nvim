local M = {}

local main = require'telescope._extensions.repo.main'
local utils = require'telescope._extensions.repo.utils'
local health = require'health'

local function get_version(binary)
	local handle = io.popen(binary .. " --version")
	local version = handle:read("*a")
	handle:close()
	return version
end

M.check = function()
	fd_bin = utils.find_fd_binary()
	if fd_bin ~= "" then
		health.report_ok("fd: found `"..fd_bin.."`\n"..get_version(fd_bin))
	else
		health.report_error("`list` will not function without [fd](https://github.com/sharkdp/fd)")
	end

	locate_bin = utils.find_locate_binary()
	if locate_bin ~= "" then
		health.report_ok("locate: found `"..locate_bin.."`\n"..get_version(locate_bin))
	else
		health.report_error("`cached_list` will not function without locate")
	end

	-- TODO Add warning if glow or bat is not found
end

return M

local M = {}

local main = require("telescope._extensions.repo.main")
local utils = require("telescope._extensions.repo.utils")
local health = require("health")

local function get_version(binary)
	local handle = io.popen(binary .. " --version")
	local version = handle:read("*a")
	handle:close()
	return version
end

local function check_list_cmd()
	fd_bin = utils.find_fd_binary()
	if fd_bin ~= "" then
		health.report_ok("fd: found `" .. fd_bin .. "`\n" .. get_version(fd_bin))
	else
		health.report_error("`list` will not function without [fd](https://github.com/sharkdp/fd)")
	end
end

local function check_cached_list_cmd()
	locate_bin = utils.find_locate_binary()
	if locate_bin ~= "" then
		health.report_ok("locate: found `" .. locate_bin .. "`\n" .. get_version(locate_bin))
	else
		health.report_error("`cached_list` will not function without locate")
	end
end

local function check_previewer()
	markdown_bin = utils.find_markdown_previewer_for_document("test_doc.md")
	if markdown_bin[1] ~= utils._markdown_previewer[1][1] then
		health.report_warn("Install `" .. utils._markdown_previewer[1][1] .. "` for a better preview of markdown files")
	end
	health.report_info("Will use `" .. markdown_bin[1] .. "` to preview markdown READMEs")

	generic_bin = utils.find_generic_previewer_for_document("test_doc")
	if generic_bin[1] ~= utils._generic_previewer[1][1] then
		health.report_warn(
			"Install `" .. utils._generic_previewer[1][1] .. "` for a better preview of non-markdown files"
		)
	end
	health.report_info("Will use `" .. generic_bin[1] .. "` to preview non-markdown READMEs")
end

M.check = function()
	check_list_cmd()
	check_cached_list_cmd()
	check_previewer()
end

return M

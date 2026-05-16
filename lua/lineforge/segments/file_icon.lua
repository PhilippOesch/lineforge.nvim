--- File icon segment
---
--- Displays an icon for the current filetype. Requires `nvim-web-devicons`.
--- The icon is colored using the color provided by the icon library.
---
---@toc_entry File icon
---@tag lineforge-segments-file_icon
local M = {}

---@private
---@param bld lineforge.Builder
---@param hl? lineforge.hl_val
function M.add(bld)
	bld:when(function(bld)
		bld:add(function()
			local filename = bld.ctx:get_filename()
			local extension = vim.fn.fnamemodify(filename, ":e")
			local icon, _ = bld.ctx:get_file_icon(filename, extension)
			return icon
		end, function()
			local filename = bld.ctx:get_filename()
			local extension = vim.fn.fnamemodify(filename, ":e")
			local _, icon_color = bld.ctx:get_file_icon(filename, extension)
			return { fg = icon_color }
		end)
	end, function()
		local filename = bld.ctx:get_filename()
		local extension = vim.fn.fnamemodify(filename, ":e")
		local icon, _ = bld.ctx:get_file_icon(filename, extension)
		return icon ~= nil
	end)
end

return M

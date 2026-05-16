local M = {}

---@param bld Builder
---@param hl? hl_val
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

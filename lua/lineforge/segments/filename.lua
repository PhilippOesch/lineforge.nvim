local M = {}

---@param bld Builder
---@param hl? hl_val
function M.add(bld, hl)
	bld:add(function()
		return bld.ctx:get_filename()
	end, hl)
end

return M

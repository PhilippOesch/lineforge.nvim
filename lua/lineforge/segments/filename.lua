local M = {}

---@param bld lineforge.Builder
---@param hl? lineforge.hl_val
function M.add(bld, hl)
	bld:add(function()
		return bld.ctx:get_filename()
	end, hl)
end

return M

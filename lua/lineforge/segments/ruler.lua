local M = {}

---@param bld Builder
---@param hl? hl_val
function M.add(bld, hl)
	bld:add(function()
		return "%7(%l/%3L%):%2c %P"
	end, hl)
end

return M

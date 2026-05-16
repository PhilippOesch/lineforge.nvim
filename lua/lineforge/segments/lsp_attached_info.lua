local M = {}

---@param bld lineforge.Builder
---@param hl? lineforge.hl_val
function M.add(bld, hl)
	bld:when(function(bld)
		bld:add(function()
			local names = bld.ctx:get_lsp_client_names()
			return "󰣖 " .. table.concat(names, ",") .. ""
		end, hl)
	end, function()
		return #bld.ctx:get_lsp_client_names() > 0
	end)
end

return M

--- Fileformat segment
---
--- Displays the current file format (`unix`, `dos`, `mac`) prefixed
--- with a format icon. Hidden when the format is unavailable.
---
---@toc_entry Fileformat
---@tag lineforge-segments-fileformat
local M = {}

---@private
---@param bld lineforge.Builder
---@param hl? lineforge.hl_val
function M.add(bld, hl)
	bld:when(function(bld)
		bld:add(function()
			local fmt = bld.ctx:get_fileformat()
			return ' ' .. fmt
		end, hl)
	end, function()
		return bld.ctx:get_fileformat() ~= nil
	end)
end

return M

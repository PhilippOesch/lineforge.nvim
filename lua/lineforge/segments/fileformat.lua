--- Fileformat segment
---
--- Displays the current file format (`unix`, `dos`, `mac`) prefixed
--- with a format icon. Hidden when the format is unavailable.
---
---@toc_entry Fileformat
---@tag lineforge-segments-fileformat
local M = {}

--- options for segment add function.
---
---@class lineforge.segments.Fileformat.opts
---@field hl? lineforge.hl_val

---@private
---@param bld lineforge.Builder
---@param opts? lineforge.segments.Fileformat.opts
function M.add(bld, opts)
	bld:when(function()
		return bld.ctx:get_fileformat() ~= nil
	end, function(bld)
		bld:add(function()
			local fmt = bld.ctx:get_fileformat()
			return " " .. fmt
		end, require("lineforge.utils").resolve_opts_hl(opts))
	end)
end

return M

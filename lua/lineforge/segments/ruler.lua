--- Ruler segment
---
--- Displays the current cursor position in the form `line/total:col percent`.
---
---@toc_entry Ruler
---@tag lineforge-segments-ruler
local M = {}

--- options for segment add function.
---
---@class lineforge.segments.Ruler.opts
---@field hl? lineforge.hl_val

---@private
---@param bld lineforge.Builder
---@param opts? lineforge.segments.Ruler.opts
function M.add(bld, opts)
	bld:add(function()
		return "%7(%l/%3L%):%2c %P"
	end, require("lineforge.utils").resolve_opts_hl(opts))
end

return M

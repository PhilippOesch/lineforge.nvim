--- Scrollbar segment
---
--- Displays a visual scrollbar indicator using Unicode block characters.
--- The indicator changes based on the current cursor position in the buffer.
---
---@toc_entry Scrollbar
---@tag lineforge-segments-scrollbar
local M = {}

local scroll_bar = { " ", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

--- options for segment add function.
---
---@class lineforge.segments.Scrollbar.opts
---@field hl? lineforge.hl_val

---@private
---@param bld lineforge.Builder
---@param opts? lineforge.segments.Scrollbar.opts
function M.add(bld, opts)
	bld:add(function()
		local curr_line = bld.ctx:get_cursor_line()
		local lines = bld.ctx:get_buffer_line_count()
		local i = math.floor((curr_line - 1) / lines * #scroll_bar) + 1
		return string.rep(scroll_bar[i], 2)
	end, require("lineforge.utils").resolve_opts_hl(opts))
end

return M

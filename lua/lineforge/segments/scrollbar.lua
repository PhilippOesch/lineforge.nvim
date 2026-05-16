--- Scrollbar segment
---
--- Displays a visual scrollbar indicator using Unicode block characters.
--- The indicator changes based on the current cursor position in the buffer.
---
---@toc_entry Scrollbar
---@tag lineforge-segments-scrollbar
local M = {}

local scroll_bar = { " ", "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

---@private
---@param bld lineforge.Builder
---@param hl? lineforge.hl_val
function M.add(bld, hl)
  bld:add(function()
    local curr_line = bld.ctx:get_cursor_line()
    local lines = bld.ctx:get_buffer_line_count()
    local i = math.floor((curr_line - 1) / lines * #scroll_bar) + 1
    return string.rep(scroll_bar[i], 2)
  end, hl)
end

return M

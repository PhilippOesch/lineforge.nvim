--- Filename segment
---
--- Displays the current buffer filename (relative to the working directory).
---
---@toc_entry Filename
---@tag lineforge-segments-filename
local M = {}

---@private
---@param bld lineforge.Builder
---@param hl? lineforge.hl_val
function M.add(bld, hl)
  bld:add(function()
    return bld.ctx:get_filename()
  end, hl)
end

return M

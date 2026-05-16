--- Ruler segment
---
--- Displays the current cursor position in the form `line/total:col percent`.
---
---@toc_entry Ruler
---@tag lineforge-segments-ruler
local M = {}

---@private
---@param bld lineforge.Builder
---@param hl? lineforge.hl_val
function M.add(bld, hl)
  bld:add(function()
    return "%7(%l/%3L%):%2c %P"
  end, hl)
end

return M

--- Filename segment
---
--- Displays the current buffer filename (relative to the working directory).
---
---@toc_entry Filename
---@tag lineforge-segments-filename
local M = {}

---@class lineforge.filename.opts
---@field hl lineforge.hl_val

---@private
---@param bld lineforge.Builder
---@param opts? lineforge.filename.opts
function M.add(bld, opts)
  bld:add(function()
    return bld.ctx:get_filename()
  end, opts and opts.hl)
end

return M

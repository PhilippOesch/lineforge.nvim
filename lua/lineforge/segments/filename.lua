--- Filename segment
---
--- Displays the current buffer filename (relative to the working directory).
---
---@toc_entry Filename
---@tag lineforge-segments-filename
local M = {}

---@class lineforge.filename.opts
---@field hl? lineforge.hl_val
---@field ignore_filetypes? string[]

---@private
---@param bld lineforge.Builder
---@param opts? lineforge.filename.opts
function M.add(bld, opts)
  if opts and opts.ignore_filetypes then
    bld:when(function()
      return not (bld.ctx:get_filetype() and vim.tbl_contains(opts.ignore_filetypes, bld.ctx:get_filetype()))
    end, function(bld)
      bld:add(function()
        return bld.ctx:get_filename()
      end, opts and opts.hl)
    end)
  else
    bld:add(function()
      return bld.ctx:get_filename()
    end, opts and opts.hl)
  end
end

return M

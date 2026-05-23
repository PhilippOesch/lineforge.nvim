---@type lineforge.segments.Filename
local Filename = {}

--- Filename segment
---
--- Displays the current buffer filename (relative to the working directory).
--- Optionally truncates from the middle when `opts.max_width` is set.
---
---@toc_entry Filename
---@tag lineforge.segments.Filename
---@class lineforge.segments.Filename
---@field add fun(bld: lineforge.Builder, opts?: lineforge.segments.Filename.opts)

--- options for segment add function.
---
---@class lineforge.segments.Filename.opts
---@field hl? lineforge.hl_val
---@field ignore_filetypes? string[]
---@field max_width? integer maximum display width; truncates from the middle if exceeded

--- add segment to builder.
---
---@param bld lineforge.Builder
---@param opts? lineforge.segments.Filename.opts
function Filename.add(bld, opts)
  local function get_text()
    local text = bld.ctx:get_filename()
    if opts and opts.max_width then
      local utils = require("lineforge.utils")
      return utils.truncate_middle(text, opts.max_width)
    end
    return text
  end

  if opts and opts.ignore_filetypes then
    bld:when(function()
      return not (bld.ctx:get_filetype() and vim.tbl_contains(opts.ignore_filetypes, bld.ctx:get_filetype()))
    end, function(bld)
      bld:add(get_text, require("lineforge.utils").resolve_opts_hl(opts))
    end)
  else
    bld:add(get_text, require("lineforge.utils").resolve_opts_hl(opts))
  end
end

return Filename

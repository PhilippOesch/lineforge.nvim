--- File icon segment
---
--- Displays an icon for the current filetype. Requires `nvim-web-devicons`.
--- The icon is colored using the color provided by the icon library.
---
---@toc_entry File icon
---@tag lineforge-segments-file_icon
local M = {}

---@class lineforge.file_icon.opts options for file_icon segment.
---@field ignore_filetypes? string[] filtypes to ignore for adding segment.

--- add segment to builder.
---
---@param bld lineforge.Builder The builder.
---@param opts lineforge.file_icon.opts options.
function M.add(bld, opts)
  bld:when(function()
    if
      opts
      and opts.ignore_filetypes
      and bld.ctx:get_filetype()
      and vim.tbl_contains(opts.ignore_filetypes, bld.ctx:get_filetype())
    then
      return false
    end
    local filename = bld.ctx:get_filename()
    local extension = vim.fn.fnamemodify(filename, ":e")
    local icon, _ = bld.ctx:get_file_icon(filename, extension)
    return icon ~= nil
  end, function(bld)
    bld:add(function()
      local filename = bld.ctx:get_filename()
      local extension = vim.fn.fnamemodify(filename, ":e")
      local icon, _ = bld.ctx:get_file_icon(filename, extension)
      return icon
    end, function()
      local filename = bld.ctx:get_filename()
      local extension = vim.fn.fnamemodify(filename, ":e")
      local _, icon_color = bld.ctx:get_file_icon(filename, extension)
      return { fg = icon_color }
    end)
  end)
end

return M

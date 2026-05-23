--- Git branch segment
---
--- Displays the current Git branch name prefixed with a branch icon.
--- Hidden when not in a Git repository. Uses `gitsigns.nvim` data if available.
--- Optionally truncates from the tail when `opts.max_width` is set.
---
---@toc_entry Git branch
---@tag lineforge-segments-git_branch
local M = {}

--- options for segment add function.
---
---@class lineforge.segments.GitBranch.opts
---@field hl? lineforge.hl_val
---@field max_width? integer maximum display width; truncates from the tail if exceeded

---@private
---@param bld lineforge.Builder
---@param opts? lineforge.segments.GitBranch.opts
function M.add(bld, opts)
  bld:when(function()
    return bld.ctx:get_git_branch() ~= nil
  end, function(bld)
    bld:add(function()
      local text = " " .. bld.ctx:get_git_branch()
      if opts and opts.max_width then
        local utils = require("lineforge.utils")
        return utils.truncate_tail(text, opts.max_width)
      end
      return text
    end, require("lineforge.utils").resolve_opts_hl(opts))
  end)
end

return M

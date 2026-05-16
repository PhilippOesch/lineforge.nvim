--- Git status segment
---
--- Displays a summary of Git diff stats: added (`+n`), removed (`-n`),
--- and changed (`~n`). Hidden when there are no changes or outside a Git
--- repository. Uses `gitsigns.nvim` data if available.
---
---@toc_entry Git status
---@tag lineforge-segments-git_status
local M = {}

---@private
---@param bld lineforge.Builder
---@param hl? lineforge.hl_val
function M.add(bld, hl)
  bld:when(function()
    return bld.ctx:get_git_status() ~= nil
  end, function(bld)
    bld
      :push_style(hl or { fg = bld.ctx:get_highlight("Constant").fg })
      :add("(")
      :when(function()
        local status = bld.ctx:get_git_status()
        return status ~= nil and status.added ~= nil and status.added > 0
      end, function(bld)
        bld:add(function()
          return "+" .. bld.ctx:get_git_status().added
        end, { fg = bld.ctx:get_highlight("Added").fg })
      end)
      :when(function()
        local status = bld.ctx:get_git_status()
        return status ~= nil and status.removed ~= nil and status.removed > 0
      end, function(bld)
        bld:add(function()
          return "-" .. bld.ctx:get_git_status().removed
        end, { fg = bld.ctx:get_highlight("Removed").fg })
      end)
      :when(function()
        local status = bld.ctx:get_git_status()
        return status ~= nil and status.changed ~= nil and status.changed > 0
      end, function(bld)
        bld:add(function()
          return "~" .. bld.ctx:get_git_status().changed
        end, { fg = bld.ctx:get_highlight("Changed").fg })
      end)
      :add(")")
      :pop_style()
  end)
end

return M

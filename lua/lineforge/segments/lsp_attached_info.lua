--- LSP attached info segment
---
--- Displays the names of LSP clients attached to the current buffer,
--- prefixed with an LSP icon. Hidden when no LSP clients are attached.
---
---@toc_entry LSP attached info
---@tag lineforge-segments-lsp_attached_info
local M = {}

---@private
---@param bld lineforge.Builder
---@param hl? lineforge.hl_val
function M.add(bld, hl)
  bld:when(function()
    return #bld.ctx:get_lsp_client_names() > 0
  end, function(bld)
    bld:add(function()
      local names = bld.ctx:get_lsp_client_names()
      return "󰣖 " .. table.concat(names, ",") .. ""
    end, hl)
  end)
end

return M

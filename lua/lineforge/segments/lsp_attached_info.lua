--- LSP attached info segment
---
--- Displays the names of LSP clients attached to the current buffer,
--- prefixed with an LSP icon. Hidden when no LSP clients are attached.
---
---@toc_entry LSP attached info
---@tag lineforge-segments-lsp_attached_info
local M = {}

--- options for segment add function.
---
---@class lineforge.segments.LspAttachedInfo.opts
---@field hl? lineforge.hl_val

---@private
---@param bld lineforge.Builder
---@param opts? lineforge.segments.LspAttachedInfo.opts
function M.add(bld, opts)
	bld:when(function()
		return #bld.ctx:get_lsp_client_names() > 0
	end, function(bld)
		bld:add(function()
			local names = bld.ctx:get_lsp_client_names()
			return "󰣖 " .. table.concat(names, ",") .. ""
		end, require("lineforge.utils").resolve_opts_hl(opts))
	end)
end

return M

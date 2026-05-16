--- Git branch segment
---
--- Displays the current Git branch name prefixed with a branch icon.
--- Hidden when not in a Git repository. Uses `gitsigns.nvim` data if available.
---
---@toc_entry Git branch
---@tag lineforge-segments-git_branch
local M = {}

---@private
---@param bld lineforge.Builder
---@param hl? lineforge.hl_val
function M.add(bld, hl)
	bld:when(function(bld)
		bld:add(function()
			return " " .. bld.ctx:get_git_branch()
		end, hl)
	end, function()
		return bld.ctx:get_git_branch() ~= nil
	end)
end

return M

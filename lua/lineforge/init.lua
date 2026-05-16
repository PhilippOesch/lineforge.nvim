local builder = require("lineforge.builder")
local context = require("lineforge.context")

---@class lineforge.config
---@field statusline? fun(builder: Builder)
---@field context? EditorContext

local M = {}

local statusline_builder

---@param opts lineforge.config
M.setup = function(opts)
	local ctx = context.default()
	if opts.context then
		ctx = vim.tbl_extend("force", ctx, opts.context)
	end

	if opts.statusline then
		statusline_builder = builder.new(nil, ctx)
		opts.statusline(statusline_builder)
		vim.o.statusline = "%{%v:lua.require'lineforge'.eval_statusline()%}"
	else
		vim.notify("No statusline configuration available", vim.log.levels.WARN)
	end
end

M.eval_statusline = function()
	if statusline_builder then
		return statusline_builder:build()
	end
end

M.segments = require("lineforge.segments")
M.context = {
	default = context.default,
}

return M

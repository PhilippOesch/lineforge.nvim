--- *lineforge* Statusline builder
---
--- MIT License Copyright (c) 2025 Philipp Oeschger
---
--- A lightweight, extensible statusline builder for Neovim.
---
--- # Features ~
--- - Simple fluent builder API for constructing statuslines.
--- - Pre-built segments for common statusline elements.
--- - Automatic highlight group creation and caching.
--- - Customizable context for fetching editor state.
--- - Zero dependencies; optional `nvim-web-devicons` support.
---
--- # Dependencies ~
--- - Neovim >= 0.8.0
---
--- Suggested dependencies (provide extra functionality, will work without them):
--- - `nvim-tree/nvim-web-devicons` for file icons in |lineforge-segments-file_icon|.
--- - `lewis6991/gitsigns.nvim` for git branch and status in
---   |lineforge-segments-git_branch| and |lineforge-segments-git_status|.
---
--- # Setup ~
---
--- This module needs a setup with `require('lineforge').setup({})`
--- (replace `{}` with your config table).
---
--- See |lineforge.config| for config structure and default values.
---@toc_entry lineforge

local builder = require("lineforge.builder")
local context = require("lineforge.context")

--- Module config
---
---@class lineforge.config
---@field statusline? fun(builder: Builder) Function that receives a |Builder| to construct the statusline.
---@field context? EditorContext Overrides for the default |EditorContext|.

local M = {}

local statusline_builder

--- Module setup
---
--- Initializes the statusline. The `{statusline}` callback receives a fresh
--- |Builder| where you compose segments and layout.
---
---@param opts lineforge.config Module config table. See |lineforge.config|.
---
---@usage >lua
---   require('lineforge').setup({
---     statusline = function(bld)
---       local s = require('lineforge').segments
---       bld
---         :section(function(b)
---           s.mode.add(b)
---           b:add_space(" ", 2)
---           s.filename.add(b)
---         end)
---         :section(function(b)
---           s.ruler.add(b)
---         end)
---     end,
---   })
--- <
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

--- Evaluate the current statusline string.
---
--- This is called automatically via the `statusline` option set during setup.
---
---@return string Statusline string.
M.eval_statusline = function()
	if statusline_builder then
		return statusline_builder:build()
	end
	return ""
end

M.segments = require("lineforge.segments")
M.context = {
	default = context.default,
}

return M

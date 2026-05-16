---@class lineforge.EditorContext
---@field get_mode fun(): string
---@field get_git_branch fun(): string?
---@field get_git_status fun(): {head?: string, added?: integer, removed?: integer, changed?: integer}?
---@field get_lsp_client_names fun(): string[]
---@field get_file_icon fun(filename: string, extension: string): (string?, string?)
---@field get_filename fun(): string
---@field get_fileformat fun(): string?
---@field get_cursor_line fun(): integer
---@field get_buffer_line_count fun(): integer
---@field get_highlight fun(name: string): table

local M = {}

---@return lineforge.EditorContext
function M.default()
	local highlight = require("lineforge.highlight")
	local web_icons_available, web_icons = pcall(require, "nvim-web-devicons")

	return {
		get_mode = function(_)
			return vim.fn.mode(1)
		end,

		get_git_branch = function(_)
			if vim.b.gitsigns_status_dict and vim.b.gitsigns_status_dict.head then
				return vim.b.gitsigns_status_dict.head
			end
			if vim.b.gitsigns_head then
				return vim.b.gitsigns_head
			end
			return nil
		end,

		get_git_status = function(_)
			if vim.b.gitsigns_status_dict then
				local s = vim.b.gitsigns_status_dict
				if not (s.added == 0 and s.removed == 0 and s.changed == 0) then
					return s
				end
			end
			return nil
		end,

		get_lsp_client_names = function(_)
			local names = {}
			for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
				table.insert(names, server.name)
			end
			return names
		end,

		get_file_icon = function(_, filename, extension)
			if web_icons_available then
				return web_icons.get_icon_color(filename, extension, { default = true })
			end
			return nil, nil
		end,

		get_filename = function(_)
			return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
		end,

		get_fileformat = function(_)
			return vim.bo.fileformat
		end,

		get_cursor_line = function(_)
			return vim.api.nvim_win_get_cursor(0)[1]
		end,

		get_buffer_line_count = function(_)
			return vim.api.nvim_buf_line_count(0)
		end,

		get_highlight = function(_, name)
			return highlight.get_highlight(name)
		end,
	}
end

return M

local MiniTest = require("mini.test")

local T = MiniTest.new_set()

-- Helper: fresh child Neovim process for each case
local child = MiniTest.new_child_neovim()

local function mock_highlight()
	child.lua([[                                                           
		package.loaded['lineforge.highlight'] = {                 
			eval_hl = function(hl)  
				return (hl.bg or 'noBg') .. '_' .. (hl.fg or 'noFg')
			end,                    
			load_colors = function() end,                                  
			get_highlight = function(name)
				local split = vim.split(name, '_')
				return {fg = split[2], bg=split[1]}
			end,                  
		}                                                                  
         ]])
end

T["segments"] = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ "-u", "scripts/minimal_init.lua" })
			mock_highlight()
		end,
	},
})

T["segments"]["mode - gets vim mode"] = function()
	local result = child.lua([[
		vim.fn.mode = function()
			return 'n'
		end

		local builder = require('lineforge.builder')
		local mode = require('lineforge.segments.mode')
		local b = builder.new()
		mode.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(result, "%#noBg_noFg#%(N%)%*")
end

T["segments"]["mode - surrounding keeps background color"] = function()
	local result = child.lua([[
		vim.fn.mode = function()
			return 'n'
		end

		local builder = require('lineforge.builder')
		local mode = require('lineforge.segments.mode')
		local b = builder.new():wrap('(',')',function(bld)
			mode.add(bld)
		end, {fg = 'MockHl'})
		return b:build()
	]])
	MiniTest.expect.equality(result, "%#noBg_MockHl#(%*%#MockHl_noFg#%(N%)%*%#noBg_MockHl#)%*")
end

T["segments"]["file_icon - icons and colors are processed as expected"] = function()
	local result = child.lua([[
		package.loaded['nvim-web-devicons'] = {
			get_icon_color = function(name)
				return 'icon', 'iconcolor'
			end,
		}

		local builder = require('lineforge.builder')
		local file_icon = require('lineforge.segments.file_icon')
		local b = builder.new()
		file_icon.add(b)

		return b:build()
	]])
	MiniTest.expect.equality(result, "%#noBg_iconcolor#icon%*")
end

T["segments"]["file_icon - should not be processed when web_icons not available"] = function()
	local result = child.lua([[
		package.loaded['nvim-web-devicons'] = nil
		local builder = require('lineforge.builder')
		local file_icon = require('lineforge.segments.file_icon')
		local b = builder.new()
		file_icon.add(b)

		return b:build()
	]])
	MiniTest.expect.equality(result, "")
end

T["segments"]["filename - expected vim api functions are called expected times"] = function()
	local result = child.lua([[
		local res = {
			nvim_buf_get_name_called = 0,
			fnamemodify = 0
		}
		vim.fn.fnamemodify = function()
			res.fnamemodify = res.fnamemodify + 1
			return ''
		end
		vim.api.nvim_buf_get_name = function()
			res.nvim_buf_get_name_called = res.nvim_buf_get_name_called + 1
			return ''
		end

		local builder = require('lineforge.builder')
		local filename = require('lineforge.segments.filename')
		local b = builder.new()
		filename.add(b)
		b:build()

		return res
	]])
	MiniTest.expect.equality(result.nvim_buf_get_name_called, 1)
	MiniTest.expect.equality(result.fnamemodify, 1)
end

T["segments"]["scrollbar - at first line returns space characters"] = function()
	local result = child.lua([[
		vim.api.nvim_win_get_cursor = function() return {1} end
		vim.api.nvim_buf_line_count = function() return 9 end

		local builder = require('lineforge.builder')
		local scrollbar = require('lineforge.segments.scrollbar')
		local b = builder.new()
		scrollbar.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(result, "  ")
end

T["segments"]["scrollbar - at last line returns full block"] = function()
	local result = child.lua([[
		vim.api.nvim_win_get_cursor = function() return {9} end
		vim.api.nvim_buf_line_count = function() return 9 end

		local builder = require('lineforge.builder')
		local scrollbar = require('lineforge.segments.scrollbar')
		local b = builder.new()
		scrollbar.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(result, "██")
end

T["segments"]["scrollbar - at middle line returns correct partial block"] = function()
	local result = child.lua([[
		vim.api.nvim_win_get_cursor = function() return {5} end
		vim.api.nvim_buf_line_count = function() return 8 end

		local builder = require('lineforge.builder')
		local scrollbar = require('lineforge.segments.scrollbar')
		local b = builder.new()
		scrollbar.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(result, "▄▄")
end

T["segments"]["scrollbar - highlight is applied correctly"] = function()
	local result = child.lua([[
		vim.api.nvim_win_get_cursor = function() return {9} end
		vim.api.nvim_buf_line_count = function() return 9 end

		local builder = require('lineforge.builder')
		local scrollbar = require('lineforge.segments.scrollbar')
		local b = builder.new()
		scrollbar.add(b, {fg = "#00FF00"})
		return b:build()
	]])
	MiniTest.expect.equality(result, "%#noBg_#00FF00#██%*")
end

T["segments"]["scrollbar - vim api functions are called expected times"] = function()
	local result = child.lua([[
		local res = {
			nvim_win_get_cursor_called = 0,
			nvim_buf_line_count_called = 0,
		}
		vim.api.nvim_win_get_cursor = function()
			res.nvim_win_get_cursor_called = res.nvim_win_get_cursor_called + 1
			return {1}
		end
		vim.api.nvim_buf_line_count = function()
			res.nvim_buf_line_count_called = res.nvim_buf_line_count_called + 1
			return 9
		end

		local builder = require('lineforge.builder')
		local scrollbar = require('lineforge.segments.scrollbar')
		local b = builder.new()
		scrollbar.add(b)
		b:build()

		return res
	]])
	MiniTest.expect.equality(result.nvim_win_get_cursor_called, 1)
	MiniTest.expect.equality(result.nvim_buf_line_count_called, 1)
end

T["segments"]["ruler - returns correct format string"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local ruler = require('lineforge.segments.ruler')
		local b = builder.new()
		ruler.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(result, "%7(%l/%3L%):%2c %P")
end

T["segments"]["ruler - highlight is applied correctly"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local ruler = require('lineforge.segments.ruler')
		local b = builder.new()
		ruler.add(b, {fg = "#00FF00"})
		return b:build()
	]])
	MiniTest.expect.equality(result, "%#noBg_#00FF00#%7(%l/%3L%):%2c %P%*")
end

T["segments"]["git_branch - gets branch from gitsigns"] = function()
	local result = child.lua([[
		vim.b.gitsigns_status_dict = {
			head = 'branch'
		}

		local builder = require('lineforge.builder')
		local git_branch = require('lineforge.segments.git_branch')
		local b = builder.new()
		git_branch.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(result, " branch")
end

T["segments"]["git_branch - do not add git branch when gitsigns not available"] = function()
	local result = child.lua([[
		vim.b.gitsigns_status_dict = nil
		local builder = require('lineforge.builder')
		local git_branch = require('lineforge.segments.git_branch')
		local b = builder.new()
		git_branch.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(result, "")
end

T["segments"]["git_branch - hl is processed"] = function()
	local result = child.lua([[
		vim.b.gitsigns_status_dict = {
			head = 'branch'
		}

		local builder = require('lineforge.builder')
		local git_branch = require('lineforge.segments.git_branch')
		local b = builder.new()
		git_branch.add(b, {fg= 'fg'})
		return b:build()
	]])
	MiniTest.expect.equality(result, "%#noBg_fg# branch%*")
end

T["segments"]["lsp_attached_info - doesn't show anything if no lsp attached"] = function()
	local result = child.lua([[
		vim.lsp.get_clients = function()
			return {}
		end

		local builder = require('lineforge.builder')
		local lsp_attached_info = require('lineforge.segments.lsp_attached_info')
		local b = builder.new()
		lsp_attached_info.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(result, "")
end

T["segments"]["lsp_attached_info - does show lsp when attached"] = function()
	local result = child.lua([[
		vim.lsp.get_clients = function()
			return {{name='lsp'}}
		end

		local builder = require('lineforge.builder')
		local lsp_attached_info = require('lineforge.segments.lsp_attached_info')
		local b = builder.new()
		lsp_attached_info.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(result, "󰣖 lsp")
end

T["segments"]["lsp_attached_info - concatenates all attached lsps"] = function()
	local result = child.lua([[
		vim.lsp.get_clients = function()
			return {{name='lsp1'}, {name='lsp2'}}
		end

		local builder = require('lineforge.builder')
		local lsp_attached_info = require('lineforge.segments.lsp_attached_info')
		local b = builder.new()
		lsp_attached_info.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(result, "󰣖 lsp1,lsp2")
end

T["segments"]["lsp_attached_info - hl is processed"] = function()
	local result = child.lua([[
		vim.lsp.get_clients = function()
			return {{name='lsp'}}
		end

		local builder = require('lineforge.builder')
		local lsp_attached_info = require('lineforge.segments.lsp_attached_info')
		local b = builder.new()
		lsp_attached_info.add(b, {fg = 'fg'})
		return b:build()
	]])
	MiniTest.expect.equality(result, "%#noBg_fg#󰣖 lsp%*")
end

T["segments"]["fileformat - displays file format"] = function()
	local result = child.lua([[
		vim.bo.fileformat = 'unix'

		local builder = require('lineforge.builder')
		local fileformat = require('lineforge.segments.fileformat')
		local b = builder.new()
		fileformat.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(result, " unix")
end

T["segments"]["fileformat - displays file format and adds highlight"] = function()
	local result = child.lua([[
		vim.bo.fileformat = 'unix'

		local builder = require('lineforge.builder')
		local fileformat = require('lineforge.segments.fileformat')
		local b = builder.new()
		fileformat.add(b, {fg = 'fg'})
		return b:build()
	]])
	MiniTest.expect.equality(result, "%#noBg_fg# unix%*")
end

T["segments"]["git_status - displays nothing when no status available"] = function()
	local result = child.lua([[
		vim.b.gitsigns_status_dict = nil
		
		local builder = require('lineforge.builder')
		local git_status = require('lineforge.segments.git_status')
		local b = builder.new()
		git_status.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(result, "")
end

T["segments"]["git_status - displays nothing when no changes available"] = function()
	local result = child.lua([[
		vim.b.gitsigns_status_dict = {
			added = 0,
			removed = 0,
			changed = 0
		}
		
		local builder = require('lineforge.builder')
		local git_status = require('lineforge.segments.git_status')
		local b = builder.new()
		git_status.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(result, "")
end

T["segments"]["git_status - displays number of added files"] = function()
	local result = child.lua([[
		package.loaded['lineforge.highlight'] = {                 
			eval_hl = function(hl)  
				return (hl.bg or 'noBg') .. '_' .. (hl.fg or 'noFg')
			end,                    
			get_highlight = function(name)
				local split = vim.split(name, '_')
				if #split == 1 then
					return {fg = split[1]}
				end
				return {fg = split[2], bg=split[1]}
			end,                  
		}                                                                  

		vim.b.gitsigns_status_dict = {
			added = 1
		}
		
		local builder = require('lineforge.builder')
		local git_status = require('lineforge.segments.git_status')
		local b = builder.new()
		git_status.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(
		result,
		"%#noBg_Constant#(%*%#noBg_Constant#%#noBg_Added#+1%*%*%#noBg_Constant#%*%#noBg_Constant#%*%#noBg_Constant#)%*"
	)
end

T["segments"]["git_status - displays number of removed files"] = function()
	local result = child.lua([[
		package.loaded['lineforge.highlight'] = {                 
			eval_hl = function(hl)  
				return (hl.bg or 'noBg') .. '_' .. (hl.fg or 'noFg')
			end,                    
			get_highlight = function(name)
				local split = vim.split(name, '_')
				if #split == 1 then
					return {fg = split[1]}
				end
				return {fg = split[2], bg=split[1]}
			end,                  
		}                                                                  

		vim.b.gitsigns_status_dict = {
			removed = 1
		}
		
		local builder = require('lineforge.builder')
		local git_status = require('lineforge.segments.git_status')
		local b = builder.new()
		git_status.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(
		result,
		"%#noBg_Constant#(%*%#noBg_Constant#%*%#noBg_Constant#%#noBg_Removed#-1%*%*%#noBg_Constant#%*%#noBg_Constant#)%*"
	)
end

T["segments"]["git_status - displays number of changed files"] = function()
	local result = child.lua([[
		package.loaded['lineforge.highlight'] = {                 
			eval_hl = function(hl)  
				return (hl.bg or 'noBg') .. '_' .. (hl.fg or 'noFg')
			end,                    
			get_highlight = function(name)
				local split = vim.split(name, '_')
				if #split == 1 then
					return {fg = split[1]}
				end
				return {fg = split[2], bg=split[1]}
			end,                  
		}                                                                  

		vim.b.gitsigns_status_dict = {
			changed = 1
		}
		
		local builder = require('lineforge.builder')
		local git_status = require('lineforge.segments.git_status')
		local b = builder.new()
		git_status.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(
		result,
		"%#noBg_Constant#(%*%#noBg_Constant#%*%#noBg_Constant#%*%#noBg_Constant#%#noBg_Changed#~1%*%*%#noBg_Constant#)%*"
	)
end

T["segments"]["git_status - displays all changes correctly"] = function()
	local result = child.lua([[
		package.loaded['lineforge.highlight'] = {                 
			eval_hl = function(hl)  
				return (hl.bg or 'noBg') .. '_' .. (hl.fg or 'noFg')
			end,                    
			get_highlight = function(name)
				local split = vim.split(name, '_')
				if #split == 1 then
					return {fg = split[1]}
				end
				return {fg = split[2], bg=split[1]}
			end,                  
		}                                                                  

		vim.b.gitsigns_status_dict = {
			added = 1,
			removed = 2,
			changed = 3,
		}
		
		local builder = require('lineforge.builder')
		local git_status = require('lineforge.segments.git_status')
		local b = builder.new()
		git_status.add(b)
		return b:build()
	]])
	MiniTest.expect.equality(
		result,
		"%#noBg_Constant#(%*%#noBg_Constant#%#noBg_Added#+1%*%*%#noBg_Constant#%#noBg_Removed#-2%*%*%#noBg_Constant#%#noBg_Changed#~3%*%*%#noBg_Constant#)%*"
	)
end

return T

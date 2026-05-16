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

T["builder"] = MiniTest.new_set({
	hooks = {
		pre_case = function()
			child.restart({ "-u", "scripts/minimal_init.lua" })
			mock_highlight()
		end,
	},
})

T["builder"]["setup correctly after creation"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new()
		return {#b.statusline, #b.hl_stack}
	]])
	MiniTest.expect.equality(result[1], 0)
	MiniTest.expect.equality(result[2], 0)
end

T["builder"]["new builder returns empty string"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')

		new_builder = builder.new() 

		return new_builder:build()
	]])
	MiniTest.expect.equality(result, "")
end

T["builder"]["add - string is build when passed"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')

		new_builder = builder.new():add('abc') 

		return new_builder:build()
	]])
	MiniTest.expect.equality(result, "abc")
end

T["builder"]["add - function is correctly processed"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')

		new_builder = builder.new():add(function()
			return 'abc'
		end) 

		return new_builder:build()
	]])
	MiniTest.expect.equality(result, "abc")
end

T["builder"]["add_space - returns space character"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')

		new_builder = builder.new():add_space() 

		return new_builder:build()
	]])
	MiniTest.expect.equality(result, " ")
end

T["builder"]["add_space - character + length is processed correctly."] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')

		new_builder = builder.new():add_space('|', 2) 

		return new_builder:build()
	]])
	MiniTest.expect.equality(result, "||")
end

T["builder"]["add_align - align characters are added"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')

		new_builder = builder.new():add_align()

		return new_builder:build()
	]])
	MiniTest.expect.error(result)
end

T["builder"]["push_style - does not create highlight if no string set at allo"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new():push_style(
			{fg= "#00FF00"}
		)
		return b:build()
	]])
	MiniTest.expect.equality(result, "")
end

T["builder"]["push_style - should add highlight to stack"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new():push_style(
			{fg= "#00FF00"}
		)
		return #b.hl_stack
	]])
	MiniTest.expect.equality(result, 1)
end

T["builder"]["pop_style - should remove highlight from stack"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new():push_style(
			{fg= "#00FF00"}
		):pop_style()
		return #b.hl_stack
	]])
	MiniTest.expect.equality(result, 0)
end

T["builder"]["add - highlight table should be processed as expected"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new():add(function()
			return "abc"
		end, {fg= "#00FF00"})
		return b:build()
	]])
	MiniTest.expect.equality(result, "%#noBg_#00FF00#abc%*")
end

T["builder"]["add - highlight function should be processed as expected"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new():add(function()
			return "abc"
		end, function ()
			return {fg= "#00FF00"}
		end)
		return b:build()
	]])
	MiniTest.expect.equality(result, "%#noBg_#00FF00#abc%*")
end

T["builder"]["stacking higlight groups works as expected"] = function()
	local result = child.lua([[
		package.loaded['lineforge.highlight'] = {                 
		    eval_hl = function(hl) 
			return hl.fg
		    end,                    
		    load_colors = function() end,                                  
		    get_highlight = function(name) return 
			{fg = name}
		    end,                  
		}                                                                  

		local builder = require('lineforge.builder')
		local b = builder.new()
			:push_style({fg= "MockHl1"})
			:add(function()
				return "abc"
			end, {fg= "MockHl2"})
			:add(function()
				return "def"
			end)
			:pop_style()
		return b:build()
	]])
	MiniTest.expect.equality(result, "%#MockHl2#abc%*%#MockHl1#def%*")
end

T["builder"]["pop_style - does not end group if nothing to group"] = function()
	local ok = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new():pop_style()
		return b:build()
	]])
	MiniTest.expect.equality(ok, "")
end

T["builder"]["wrap - surrounds text with surrounding characters"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new():wrap('(',')',function(bld)
			bld:add('abc')
		end)
		return b:build()
	]])
	MiniTest.expect.equality(result, "(abc)")
end

T["builder"]["wrap - surrounds text with surrounding characters and inverts highlight group properly"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new():wrap('(',')',function(bld)
			bld:add('abc')
		end, {fg = 'MockHl'})
		return b:build()
	]])
	MiniTest.expect.equality(result, "%#noBg_MockHl#(%*%#MockHl_noFg#abc%*%#noBg_MockHl#)%*")
end

T["builder"]["add_align - add expected charcters"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new():add_align()

		return b:build()
	]])
	MiniTest.expect.equality(result, "%=")
end

T["builder"]["section - two blocks are separated with aling characters"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new():section(function(bld)
			bld:add("abc")
		end)
		:section(function(bld)
			bld:add("def")
		end)

		return b:build()
	]])
	MiniTest.expect.equality(result, "abc%=def")
end

T["builder"]["when - string not added when condition not fulfilled"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new():when(function()
			return false
		end, function(bld)
			bld:add("abc")
		end)

		return b:build()
	]])
	MiniTest.expect.equality(result, "")
end

T["builder"]["when - string added when condition fulfilled"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new():when(function()
			return true
		end, function(bld)
			bld:add("abc")
		end)

		return b:build()
	]])
	MiniTest.expect.equality(result, "abc")
end

T["builder"]["when - information about highights are keeped"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new()
		:push_style({fg='mockHl'})
		:when(function()
			return true
		end, function(bld)
			bld:add("abc")
		end)
		:pop_style()

		return b:build()
	]])
	MiniTest.expect.equality(result, "%#noBg_mockHl#%#noBg_mockHl#abc%*%*")
end

T["builder"]["when - information about highights are keeped and build on"] = function()
	local result = child.lua([[
		local builder = require('lineforge.builder')
		local b = builder.new()
		:push_style({fg='fg'})
		:when(function()
			return true
		end, function(bld)
			bld:add("abc", {bg = 'bg'})
		end)
		:pop_style()

		return b:build()
	]])
	MiniTest.expect.equality(result, "%#noBg_fg#%#bg_fg#abc%*%*")
end

return T

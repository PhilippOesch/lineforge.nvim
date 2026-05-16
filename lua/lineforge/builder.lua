local highlight = require("lineforge.highlight")
local context = require("lineforge.context")

local Builder = {}
Builder.__index = Builder

---@class Builder
---@field statusline (eval_fun|string)[]
---@field hl_stack hl_val[]
---@field ctx EditorContext
---@field new fun(hl?: hl_val, ctx?: EditorContext): Builder
---@field add fun(self: Builder, fn: eval_fun, hl?: hl_val): Builder
---@field section fun(self: Builder, hl?: hl_val): Builder
---@field add_align fun(self: Builder): Builder
---@field add_space fun(self: Builder, chars?: string, len?: integer): Builder
---@field wrap fun(self: Builder, left: string, right: string, fn: eval_fun_builder, hl?: hl_val): Builder
---@field when fun(self: Builder, fn: eval_fun_builder, predicate: condition_fun): Builder
---@field push_style fun(self: Builder, hl: hl_val): Builder
---@field pop_style fun(self: Builder): Builder
---@field build fun(self: Builder): string

---@alias eval_fun fun():string
---@alias eval_fun_builder fun(bld: Builder)
---@alias condition_fun fun():boolean
---@alias hl_val table|function

---@param hl? hl_val
---@param ctx? EditorContext
---@return Builder
function Builder.new(hl, ctx)
	local self = setmetatable({}, Builder)

	---@type eval_fun[]
	self.statusline = {}
	self.hl_stack = {}
	if hl then
		self.hl_stack = { hl }
	end
	self.ctx = ctx or context.default()

	return self
end

local function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end

local function resolve_dynamic_hl(hl)
	while type(hl) == "function" do
		hl = hl()
	end
	return hl
end

---@param hl? hl_val
---@return Builder
function Builder:push_style(hl)
	local hl_fn = function()
		return highlight.eval_hl(hl)
	end

	if type(hl) == "table" and #self.hl_stack > 0 then
		local parent_hl = self.hl_stack[#self.hl_stack]
		hl_fn = function()
			local from_stack = resolve_dynamic_hl(parent_hl)
		if type(from_stack) == "string" then
			from_stack = self.ctx:get_highlight(from_stack)
		end
			return highlight.eval_hl(vim.tbl_extend("force", from_stack, hl))
		end
	end

	if type(hl) == "function" then
		local current_stack = deepcopy(self.hl_stack)
		hl_fn = function()
			local evaluated_hl = resolve_dynamic_hl(hl)
			if type(evaluated_hl) == "table" and #current_stack > 0 then
				local from_stack = resolve_dynamic_hl(current_stack[#current_stack])
			if type(from_stack) == "string" then
				from_stack = self.ctx:get_highlight(from_stack)
			end
				evaluated_hl = vim.tbl_extend("force", from_stack, evaluated_hl)
			end
			return highlight.eval_hl(evaluated_hl)
		end
	end
	table.insert(self.hl_stack, hl_fn)
	return self
end

---@return Builder
function Builder:pop_style()
	if #self.hl_stack > 0 then
		table.remove(self.hl_stack, #self.hl_stack)
	end
	return self
end

---add new eval function
---@param fn eval_fun|string
---@param hl? hl_val
---@return Builder
function Builder:add(fn, hl)
	local stack_hl = nil
	if #self.hl_stack then
		stack_hl = self.hl_stack[#self.hl_stack]
	end
	hl = hl
	local hl_fn = function()
		local resolve_hl = resolve_dynamic_hl(hl)
		local resolve_stack_hl = resolve_dynamic_hl(stack_hl)
		if type(resolve_stack_hl) == "string" then
			resolve_stack_hl = self.ctx:get_highlight(resolve_stack_hl)
		end
		if type(resolve_hl) == "table" and type(resolve_stack_hl) == "table" then
			local res = vim.tbl_extend("force", resolve_stack_hl, resolve_hl)
			return highlight.eval_hl(res)
		end
		if type(resolve_hl) == "table" or type(resolve_stack_hl) == "table" then
			return highlight.eval_hl(resolve_hl or resolve_stack_hl)
		end
		return resolve_hl or resolve_stack_hl
	end
	if hl or stack_hl then
		table.insert(self.statusline, function()
			return "%#" .. hl_fn() .. "#"
		end)
		table.insert(self.statusline, fn)
		table.insert(self.statusline, "%*")
	else
		table.insert(self.statusline, fn)
	end
	return self
end

---add new eval function
---@param fn eval_fun_builder
---@param hl? hl_val
---@return Builder
function Builder:section(fn, hl)
	if #self.statusline > 0 then
		self:add_align()
	end
	if hl then
		self:push_style(hl)
		fn(self)
		self:pop_style()
	else
		fn(self)
	end
	return self
end

---@param fn eval_fun_builder
---@param predicate condition_fun
---@return Builder
function Builder:when(fn, predicate)
	local conditional_builder = Builder.new((#self.hl_stack > 0 and self.hl_stack[#self.hl_stack]) or nil, self.ctx)
	fn(conditional_builder)
	self:add(function()
		if predicate() then
			return conditional_builder:build()
		end
		return ""
	end)
	return self
end

---@return Builder
function Builder:add_align()
	self:add("%=")
	return self
end

---comment
---@param chars? string
---@param len? integer
---@return Builder
function Builder:add_space(chars, len)
	self:add(string.rep(chars or " ", len or 1))
	return self
end

---@param left string
---@param right string
---@param fn eval_fun_builder
---@param hl? string
---@return Builder
function Builder:wrap(left, right, fn, hl)
	if hl then
		self:add(function()
			return left
		end, hl)
		self:push_style(((type(hl) == "table" and hl.fg) and { bg = hl.fg }))
		fn(self)
		self:pop_style()
		self:add(function()
			return right
		end, hl)
	else
		self:add(function()
			return left
		end)
		fn(self)
		self:add(function()
			return right
		end)
	end
	return self
end

---@return string
function Builder:build()
	local res = ""
	for _, value in ipairs(self.statusline) do
		if type(value) == "string" then
			res = res .. value
		elseif type(value) == "function" then
			res = res .. value()
		end
	end
	return res
end

return Builder

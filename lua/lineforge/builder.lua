local context = require("lineforge.context")
local highlight = require("lineforge.highlight")

---@type lineforge.Builder
local Builder = {}
Builder.__index = Builder

--- Statusline builder
---
--- The builder uses a fluent API: every method returns the builder itself,
--- allowing chained calls. Content is accumulated as a sequence of strings and
--- functions that get evaluated on every statusline redraw.
---
--- Highlights can be:
--- - A table of highlight attributes: `{ fg = "#FF0000", bg = "#000000", bold = true }`
--- - A function returning a highlight table or string.
--- - A string referencing an existing highlight group name.
---
---@toc_entry Builder
---@tag lineforge.Builder
---@class lineforge.Builder
---@field statusline (lineforge.eval_fun|string)[]
---@field hl_stack lineforge.hl_val[]
---@field ctx lineforge.EditorContext
---@field new fun(hl?: lineforge.hl_val, ctx?: lineforge.EditorContext): lineforge.Builder
---@field add fun(self: lineforge.Builder, fn: (lineforge.eval_fun|string), hl?: lineforge.hl_val): lineforge.Builder
---@field section fun(self: lineforge.Builder, hl?: lineforge.hl_val): lineforge.Builder
---@field add_align fun(self: lineforge.Builder): lineforge.Builder
---@field add_space fun(self: lineforge.Builder, chars?: string, len?: integer): lineforge.Builder
---@field wrap fun(self: lineforge.Builder, left: string, right: string, fn: lineforge.eval_fun_builder, hl?: lineforge.hl_val): lineforge.Builder
---@field when fun(self: lineforge.Builder, predicate: lineforge.condition_fun, fn: lineforge.eval_fun_builder): lineforge.Builder
---@field push_style fun(self: lineforge.Builder, hl: lineforge.hl_val): lineforge.Builder
---@field pop_style fun(self: lineforge.Builder): lineforge.Builder
---@field build fun(self: lineforge.Builder): string

---@alias lineforge.eval_fun fun():string Function that returns a string evaluated on redraw.
---@alias lineforge.eval_fun_builder fun(bld: lineforge.Builder) Builder callback used inside methods like `section` and `when`.
---@alias lineforge.condition_fun fun():boolean Predicate function returning `true` to show conditional content.
---@alias lineforge.hl_val table|function|string

--- Create a new builder
---
---@param hl? lineforge.hl_val Initial highlight pushed onto the stack.
---@param ctx? lineforge.EditorContext Context providing editor state.
---@return lineforge.Builder
function Builder.new(hl, ctx)
  local self = setmetatable({}, Builder)

  ---@type lineforge.eval_fun[]
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

---@param hl? lineforge.hl_val
--- Push a highlight onto the stack
---
--- When a table highlight is pushed, it merges with the current stack top.
--- When a function is pushed, it lazily evaluates and merges on use.
---
---@param hl lineforge.hl_val Highlight value to push.
---@return lineforge.Builder
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

--- Pop the last highlight from the stack
---
---@return lineforge.Builder
function Builder:pop_style()
  if #self.hl_stack > 0 then
    table.remove(self.hl_stack, #self.hl_stack)
  end
  return self
end

--- Add content to the statusline
---
--- Adds a string or a function that returns a string. When `{hl}` is
--- provided, the content is wrapped in the corresponding highlight group.
---
---@param fn lineforge.eval_fun|string String or function returning a string.
---@param hl? lineforge.hl_val Optional highlight for this item.
---@return lineforge.Builder
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

--- Create a new section
---
--- Wraps `{fn}` inside an alignment block. If `{hl}` is provided, the
--- entire section inherits that highlight via `push_style` / `pop_style`.
--- Inserts `%=` before the section unless it is the first block.
---
---@param fn lineforge.eval_fun_builder Builder callback defining section content.
---@param hl? lineforge.hl_val Optional highlight applied to the whole section.
---@return lineforge.Builder
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

--- Conditionally add content
---
--- Evaluates `{predicate}` on every redraw. If it returns `true`, the
--- content produced by `{fn}` is included; otherwise it is omitted.
---
---@param predicate lineforge.condition_fun Function returning `true` to include content.
---@param fn lineforge.eval_fun_builder Builder callback defining conditional content.
---@return lineforge.Builder
function Builder:when(predicate, fn)
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

--- Add an alignment separator
---
--- Inserts `%=` which separates left-aligned and right-aligned content.
---
---@return lineforge.Builder
function Builder:add_align()
  self:add("%=")
  return self
end

--- Add spacing
---
---@param chars? string Characters to repeat. Default: `" "`.
---@param len? integer Number of repetitions. Default: `1`.
---@return lineforge.Builder
function Builder:add_space(chars, len)
  self:add(string.rep(chars or " ", len or 1))
  return self
end

--- Wrap content with delimiters
---
--- Adds `{left}`, runs `{fn}` to add inner content, then adds `{right}`.
--- When `{hl}` is provided, the delimiters and inner content use that
--- highlight. For table highlights with a `fg`, the inner background is
--- automatically set to that foreground color for a "pill" effect.
---
---@param left string Left delimiter string.
---@param right string Right delimiter string.
---@param fn lineforge.eval_fun_builder Builder callback for inner content.
---@param hl? lineforge.hl_val Optional highlight for the wrapped block.
---@return lineforge.Builder
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

--- Build the statusline string
---
--- Evaluates all accumulated strings and functions to produce the final
--- statusline value.
---
---@return string Final statusline string.
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

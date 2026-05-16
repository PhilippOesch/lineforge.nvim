-- !!!This code is mostly copied from heirline.!!!: https://github.com/rebelot/heirline.nvim/blob/master/lua/heirline/highlights.lua

local M = {}
local str_format = string.format
local tbl_insert = table.insert
local tbl_concat = table.concat

local defined_highlights = {}

local loaded_colors = {}

--- Reset cached highlight groups
---
--- Clears the internal cache so that subsequent calls to |eval_hl| will
--- recreate highlight groups.
function M.reset_highlights()
  defined_highlights = {}
end

--- Load named colors
---
--- Registers color names that can be used in highlight tables instead of
--- hex strings. For example, `load_colors({ myred = "#FF0000" })` allows
--- using `{ fg = "myred" }`.
---
---@param colors table<string,string> Map of color name to hex value.
function M.load_colors(colors)
  for c, v in pairs(colors) do
    loaded_colors[c] = v
  end
end

--- Clear loaded named colors
function M.clear_colors()
  loaded_colors = {}
end

--- Get loaded named colors
---
---@return table<string,string> Copy of the loaded colors table.
function M.get_loaded_colors()
  return vim.tbl_extend("force", loaded_colors, {})
end

--- Get cached highlight group names
---
---@return table<string,boolean> Copy of the cached highlight name table.
function M.get_highlights()
  return vim.tbl_extend("force", defined_highlights, {})
end

local function make_hl(hl_name, hl)
  vim.api.nvim_set_hl(0, hl_name, hl)
end

local function get_hl_style(hl)
  local style = {}
  local valid_styles = {
    "bold",
    "standout",
    "underline",
    "undercurl",
    "underdouble",
    "underdotted",
    "underdashed",
    "strikethrough",
    "italic",
    "reverse",
  }
  for _, v in ipairs(valid_styles) do
    if hl[v] then
      tbl_insert(style, v)
    end
  end
  return tbl_concat(style, "")
end

local function name_rgb_hl(hl)
  return (str_format("Stl%s_%s_%s_%s", hl.fg or "", hl.bg or "", get_hl_style(hl), hl.sp or ""):gsub("#", ""))
end

local function name_cterm_hl(hl)
  return str_format("Stl%s_%s_%s", (hl.ctermfg or ""), (hl.ctermbg or ""), get_hl_style(hl.cterm or hl))
end

local function hex(val)
  if type(val) == "number" then
    return str_format("#%06x", val)
  else
    return val
  end
end

local function get_color(val)
  if type(val) == "string" then
    return loaded_colors[val] or val
  else
    return val
  end
end

local function normalize_hl(hl)
  local fixed_hl = vim.tbl_extend("force", hl, {})
  fixed_hl.fg = hex(get_color(hl.fg or hl.foreground))
  fixed_hl.bg = hex(get_color(hl.bg or hl.background))
  fixed_hl.sp = hex(get_color(hl.sp or hl.special))
  fixed_hl.ctermfg = get_color(hl.ctermfg)
  fixed_hl.ctermbg = get_color(hl.ctermbg)
  fixed_hl.force = nil
  return fixed_hl
end

--- Evaluate a highlight definition
---
--- Normalizes the highlight table, creates a named highlight group if it
--- does not already exist, and returns the group name for use in statusline
--- format strings (`%#GroupName#`).
---
---@param hl table Highlight definition table with keys like `fg`, `bg`, `bold`, etc.
---@return string Name of the created or cached highlight group.
function M.eval_hl(hl)
  assert(type(hl) == "table")
  if vim.tbl_isempty(hl) or hl[true] then
    return ""
  end
  hl = normalize_hl(hl)
  local name_hl = vim.o.termguicolors and name_rgb_hl or name_cterm_hl
  local hl_name = name_hl(hl)
  if not defined_highlights[hl_name] then
    make_hl(hl_name, hl)
    defined_highlights[hl_name] = true
  end
  return hl_name
end

--- Get a built-in highlight group definition
---
---@param name string Highlight group name.
---@return table Highlight definition table.
function M.get_highlight(name)
  return vim.api.nvim_get_hl(0, { name = name, link = false, create = false })
end

return M

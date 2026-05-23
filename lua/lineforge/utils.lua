--- Utility functions for LineForge
---
--- Helper functions used across segments for display-width aware
--- string manipulation.
---@tag lineforge.utils
local M = {}

local ELLIPSIS = "…"

--- Return the display width of a string.
---
---@param str string
---@return integer
function M.strdisplaywidth(str)
  return vim.fn.strdisplaywidth(str)
end

--- Truncate a string from the tail, preserving the start.
---
--- If the string fits within `max_width`, it is returned unchanged.
--- Otherwise characters are removed from the end and replaced with `…`.
---
---@param str string
---@param max_width integer
---@return string
function M.truncate_tail(str, max_width)
  local width = M.strdisplaywidth(str)
  if width <= max_width then
    return str
  end

  local ew = M.strdisplaywidth(ELLIPSIS)
  if max_width <= ew then
    return ELLIPSIS
  end

  local target = max_width - ew
  local result = ""
  local result_w = 0
  local nchars = vim.fn.strchars(str)
  for i = 0, nchars - 1 do
    local char = vim.fn.strcharpart(str, i, 1)
    local cw = M.strdisplaywidth(char)
    if result_w + cw > target then
      break
    end
    result = result .. char
    result_w = result_w + cw
  end

  return result .. ELLIPSIS
end

--- Truncate a string from the middle, preserving both ends.
---
--- If the string fits within `max_width`, it is returned unchanged.
--- Otherwise characters are removed from the middle and replaced with `…`.
---
---@param str string
---@param max_width integer
---@return string
function M.truncate_middle(str, max_width)
  local width = M.strdisplaywidth(str)
  if width <= max_width then
    return str
  end

  local ew = M.strdisplaywidth(ELLIPSIS)
  if max_width <= ew then
    return ELLIPSIS
  end

  local remaining = max_width - ew
  local prefix_target = math.floor(remaining / 2)
  local suffix_target = remaining - prefix_target

  local prefix = ""
  local prefix_w = 0
  local nchars = vim.fn.strchars(str)
  for i = 0, nchars - 1 do
    local char = vim.fn.strcharpart(str, i, 1)
    local cw = M.strdisplaywidth(char)
    if prefix_w + cw > prefix_target then
      break
    end
    prefix = prefix .. char
    prefix_w = prefix_w + cw
  end

  local suffix = ""
  local suffix_w = 0
  for i = nchars - 1, 0, -1 do
    local char = vim.fn.strcharpart(str, i, 1)
    local cw = M.strdisplaywidth(char)
    if suffix_w + cw > suffix_target then
      break
    end
    suffix = char .. suffix
    suffix_w = suffix_w + cw
  end

  return prefix .. ELLIPSIS .. suffix
end

--- Extract the highlight from an opts table, with backward compatibility.
---
--- If `opts.hl` exists, it is returned. Otherwise, if the table looks like
--- a plain highlight value (contains `fg`, `bg`, etc. and no segment
--- options like `max_width`), the table itself is returned as the highlight.
---
---@param opts table|nil
---@return lineforge.hl_val|nil
function M.resolve_opts_hl(opts)
  if not opts then
    return nil
  end
  if type(opts) ~= "table" then
    return nil
  end
  if opts.hl then
    return opts.hl
  end
  -- Backward compatibility: plain highlight tables passed as opts
  if not opts.max_width and (opts.fg or opts.bg or opts.bold or opts.italic or opts.underline) then
    return opts
  end
  return nil
end

return M

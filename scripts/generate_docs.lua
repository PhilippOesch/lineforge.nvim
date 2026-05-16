local minidoc = require("mini.doc")
if _G.MiniDoc == nil then
  minidoc.setup()
end

local hooks = vim.deepcopy(MiniDoc.default_hooks)

hooks.block_pre = function(b)
  local path = b.parent and b.parent.info and b.parent.info.path or ""
  if path:find("segments") then
    return
  end
  MiniDoc.default_hooks.block_pre(b)
end

hooks.sections["@toc_entry"] = function(s)
  MiniDoc.default_hooks.sections["@toc_entry"](s)
  s:clear_lines()
end

hooks.write_pre = function(lines)
  table.remove(lines, 1)
  table.remove(lines, 1)
  return lines
end

MiniDoc.generate({
  "lua/lineforge/init.lua",
  "lua/lineforge/builder.lua",
  "lua/lineforge/context.lua",
  "lua/lineforge/highlight.lua",
  "lua/lineforge/segments/init.lua",
  "lua/lineforge/segments/mode.lua",
  "lua/lineforge/segments/filename.lua",
  "lua/lineforge/segments/file_icon.lua",
  "lua/lineforge/segments/git_branch.lua",
  "lua/lineforge/segments/git_status.lua",
  "lua/lineforge/segments/fileformat.lua",
  "lua/lineforge/segments/lsp_attached_info.lua",
  "lua/lineforge/segments/ruler.lua",
  "lua/lineforge/segments/scrollbar.lua",
}, "doc/lineforge.txt", { hooks = hooks })

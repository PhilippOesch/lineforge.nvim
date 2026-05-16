--- Built-in segments
---
--- Pre-built statusline segments provided by LineForge. Each segment
--- exposes an `add(builder, highlight?)` function.
---
--- Available segments:
--- - `mode` — |lineforge-segments-mode|
--- - `filename` — |lineforge-segments-filename|
--- - `file_icon` — |lineforge-segments-file_icon|
--- - `git_branch` — |lineforge-segments-git_branch|
--- - `git_status` — |lineforge-segments-git_status|
--- - `fileformat` — |lineforge-segments-fileformat|
--- - `lsp_attached_info` — |lineforge-segments-lsp_attached_info|
--- - `ruler` — |lineforge-segments-ruler|
--- - `scrollbar` — |lineforge-segments-scrollbar|
---@tag lineforge-segments
return {
	git_status      = require("lineforge.segments.git_status"),
	git_branch      = require("lineforge.segments.git_branch"),
	fileformat      = require("lineforge.segments.fileformat"),
	lsp_attached_info = require("lineforge.segments.lsp_attached_info"),
	file_icon       = require("lineforge.segments.file_icon"),
	filename        = require("lineforge.segments.filename"),
	mode            = require("lineforge.segments.mode"),
	scrollbar       = require("lineforge.segments.scrollbar"),
	ruler           = require("lineforge.segments.ruler"),
}

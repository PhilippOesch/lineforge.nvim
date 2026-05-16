local mode_names = { -- change the strings if you like it vvvvverbose!
	n = "N",
	no = "N?",
	nov = "N?",
	noV = "N?",
	["no\22"] = "N?",
	niI = "Ni",
	niR = "Nr",
	niV = "Nv",
	nt = "Nt",
	v = "V",
	vs = "Vs",
	V = "V_",
	Vs = "Vs",
	["\22"] = "^V",
	["\22s"] = "^V",
	s = "S",
	S = "S_",
	["\19"] = "^S",
	i = "I",
	ic = "Ic",
	ix = "Ix",
	R = "R",
	Rc = "Rc",
	Rx = "Rx",
	Rv = "Rv",
	Rvc = "Rv",
	Rvx = "Rv",
	c = "C",
	cv = "Ex",
	r = "...",
	rm = "M",
	["r?"] = "?",
	["!"] = "!",
	t = "T",
}

local mode_colors = {
	n = "Error",
	i = "String",
	v = "Special",
	V = "Special",
	["\22"] = "Special",
	c = "Constant",
	s = "Statement",
	S = "Statement",
	["\19"] = "Statement",
	R = "Constant",
	r = "Constant",
	["!"] = "Error",
	t = "Error",
}

--- Mode segment
---
--- Displays the current Vim mode abbreviation (e.g. `N`, `I`, `V`).
--- Automatically colors the text using the mode's associated highlight group.
---
---@toc_entry Mode
---@tag lineforge-segments-mode
local M = {}

---@private
---@param bld lineforge.Builder
---@param hl? lineforge.hl_val
function M.add(bld)
	bld:add(function()
		return "%(" .. mode_names[bld.ctx:get_mode()] .. "%)"
	end, function()
		return { fg = bld.ctx:get_highlight(mode_colors[bld.ctx:get_mode()]).fg }
	end)
end

return M

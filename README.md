# LineForge

A lightweight, extensible statusline builder for Neovim.

## Features

- **Simple API**: Fluent builder pattern for constructing statuslines
- **Composable Segments**: Pre-built segments for common statusline elements
- **Highlight Management**: Automatic highlight group creation and caching
- **Context System**: Customizable context for fetching editor state
- **Zero Dependencies**: Optional `nvim-web-devicons` support for file icons

## Installation

### Using vim.pack (Neovim 0.12+)

```lua
vim.pack.add({
  { src = "https://github.com/PhilippOesch/lineforge.nvim" },
})
```

### Using other plugin managers

```lua
-- lazy.nvim
{ "PhilippOesch/lineforge.nvim" }

-- packer.nvim
use { "PhilippOesch/lineforge.nvim" }
```

## Quick Start

```lua
local lineforge = require("lineforge")
local segments = lineforge.segments

lineforge.setup({
  statusline = function(builder)
    builder
      :section(function(bld)
        segments.mode.add(bld)
        bld:add_space(" ", 2)
        segments.file_icon.add(bld)
        bld:add_space()
        segments.filename.add(bld)
      end)
      :section(function(bld)
        segments.ruler.add(bld)
        bld:add_space(" ", 2)
        segments.scrollbar.add(bld)
      end)
  end,
})
```

## Configuration

### Setup Options

```lua
---@class lineforge.config
---@field statusline? fun(builder: Builder)
---@field context? EditorContext
```

### Custom Context

You can override specific context methods or add new ones:

```lua
lineforge.setup({
  context = {
    get_git_branch = function()
      -- Your custom git branch logic
      return "main"
    end,
  },
  statusline = function(builder)
    -- ...
  end,
})
```

The default context is available at `lineforge.context.default()`.

### Available Segments

Every segment accepts an optional `opts` table:

```lua
segments.filename.add(builder, { hl = { fg = "#FF0000" }, max_width = 20 })
```

| Segment | Description | Options |
|---------|-------------|---------|
| `mode` | Current vim mode (N, I, V, etc.) | `hl` |
| `filename` | Current buffer filename | `hl`, `ignore_filetypes`, `max_width` |
| `file_icon` | File icon (requires nvim-web-devicons) | `hl`, `ignore_filetypes` |
| `git_branch` | Git branch name | `hl`, `max_width` |
| `git_status` | Git status (added/removed/changed) | `hl` |
| `lsp_attached_info` | Attached LSP client names | `hl` |
| `fileformat` | File format (unix, dos, mac) | `hl` |
| `ruler` | Line/column position | `hl` |
| `scrollbar` | Visual scrollbar indicator | `hl` |

#### Truncation

`filename` and `git_branch` support `max_width` to prevent overly long segments:

- `filename` truncates from the **middle** (`…/file.lua`).
- `git_branch` truncates from the **tail** (`feature/very-…`).

When the remaining space is too small for meaningful truncation, an ellipsis (`…`) is shown.

### Builder API

```lua
builder
  :add(string|function, hl?)          -- Add text or evaluated function
  :add_align()                         -- Add alignment separator
  :add_space(chars?, len?)             -- Add spacing
  :section(function(builder), hl?)     -- Create a new section block (spaced to have equal space between sections)
  :wrap(left, right, fn, hl?)          -- Wrap content with delimiters
  :when(condition, function(builder))  -- Conditional content
  :push_style(hl)                      -- Push highlight onto stack
  :pop_style()                         -- Pop highlight from stack
```

### Highlight Values

Highlights can be:
- **Table**: `{ fg = "#FF0000", bg = "#000000", bold = true }`
- **Function**: `function() return { fg = "#FF0000" } end`

Colors can be hex strings or named colors loaded via `highlight.load_colors({ myred = "#FF0000" })`.

## Credits

This plugin was heavily inspired by the modular design of [heirline.nvim](https://github.com/rebelot/heirline.nvim). This plugin is basically a re imagination of it The highlight evaluation logic in `lua/lineforge/highlight.lua` is derived from heirline's codebase.

## License

MIT License - see [LICENSE](LICENSE) for details.

Includes code from heirline.nvim, released under the MIT License - see [LICENSE-heirline.txt](LICENSE-heirline.txt).

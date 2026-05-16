# Agent Instructions

## Package Manager
Neovim plugin. Dependencies vendored in `deps/`.

## File-Scoped Commands
| Task | Command |
|------|---------|
| Run all tests | `nvim --headless --noplugin -u scripts/minimal_init.lua -c "lua MiniTest.run()"` |
| Run single test file | `nvim --headless --noplugin -u scripts/minimal_init.lua -c "lua MiniTest.run_file('path/to/test_file.lua')"` |


## Key Conventions
- **Indentation**: tabs
- **Source**: `lua/lineforge/` | **Tests**: `tests/lineforge/`
- **New segments**: add module in `lua/lineforge/segments/` and export in `lua/lineforge/segments/init.lua`
- **Builder API**: fluent method chaining. See `README.md` for segment list and builder methods
- **Test pattern**: `MiniTest.new_set()` with child Neovim process. See existing tests for examples

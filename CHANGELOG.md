# Changelog

## [0.1.0](https://github.com/PhilippOesch/lineforge.nvim/compare/lineforge.nvim-v0.0.3...lineforge.nvim-v0.1.0) (2026-05-23)


### ⚠ BREAKING CHANGES

* **segments:** all segments now use add(bld, opts) instead ofadd(bld, hl). Pass hl via opts.hl. Plain tables like {fg = 'red'}are still supported for backward compatibility.filename supports opts.max_width (middle truncation, very/…/file.lua).git_branch supports opts.max_width (tail truncation, feature/very-…).New lua/lineforge/utils.lua with truncate_middle, truncate_tail,strdisplaywidth helpers.

### Features

* **file_icon:** add ignore_filetypes option ([0ce021c](https://github.com/PhilippOesch/lineforge.nvim/commit/0ce021c6bf23a20d1b5b989e92589588f1e67ff5))
* **segments:** unify API under opts, add truncation ([#11](https://github.com/PhilippOesch/lineforge.nvim/issues/11)) ([0c4078c](https://github.com/PhilippOesch/lineforge.nvim/commit/0c4078c5720807876a11c80796bcdb9c410145e1))

## [0.0.3](https://github.com/PhilippOesch/lineforge.nvim/compare/lineforge.nvim-v0.0.2...lineforge.nvim-v0.0.3) (2026-05-16)


### Features

* **filename:** add highlight support ([69f62c6](https://github.com/PhilippOesch/lineforge.nvim/commit/69f62c60a76cd9758c2adabd5f24e4920c6282ca))
* **filename:** add ignore_filetypes option ([05cdbbd](https://github.com/PhilippOesch/lineforge.nvim/commit/05cdbbd691ab91108434078db93eed71084d99ad))

## [0.0.2](https://github.com/PhilippOesch/lineforge.nvim/compare/lineforge.nvim-v0.0.1...lineforge.nvim-v0.0.2) (2026-05-16)


### Features

* release plugin ([a46c499](https://github.com/PhilippOesch/lineforge.nvim/commit/a46c4991f32d78abf52b56e9642b112383788393))

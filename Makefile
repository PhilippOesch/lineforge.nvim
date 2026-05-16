deps/mini.nvim:
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/nvim-mini/mini.nvim $@

test: deps/mini.nvim
	nvim --headless --noplugin -u scripts/minimal_init.lua -c "lua MiniTest.run()"

test_file: deps/mini.nvim
	nvim --headless --noplugin -u scripts/minimal_init.lua -c "lua MiniTest.run_file('$(FILE)')"

gen_docs: deps/mini.nvim
	nvim --headless --noplugin -u scripts/minimal_init.lua -c "luafile scripts/generate_docs.lua" -c "qa"

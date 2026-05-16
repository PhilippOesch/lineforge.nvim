-- Add current directory to runtimepath to be able to use 'lua' files
vim.cmd([[let &rtp.=','.getcwd()]])

-- Assumes that 'mini.nvim' is stored in 'deps/mini.nvim'
vim.cmd("set rtp+=deps/mini.nvim")

-- Load mini.test before setup so we can reference it in config
local MiniTest = require("mini.test")

-- Set up 'mini.test' with headless-friendly reporter
MiniTest.setup({
  collect = {
    find_files = function()
      return vim.fn.globpath("tests", "**/test_*.lua", true, true)
    end,
  },
  execute = {
    reporter = MiniTest.gen_reporter.stdout(),
    stop_on_error = false,
  },
})

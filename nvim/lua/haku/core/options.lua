-- comment at 25-9-20, if after 10-1 delete
-- vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

--[[ SILENCE A SPECIFIC DEPRECATION WARNING ]]
-- This code wraps the vim.notify function to filter out a specific, persistent
-- warning that could not be traced to any specific plugin.

-- Store the original vim.notify function so we can call it for other messages
local original_notify = vim.notify

-- Define the exact text of the warning you want to silence
local warning_to_silence = "The `require('lspconfig')` \"framework\" is deprecated"

-- Redefine vim.notify with our custom filtering logic
vim.notify = function(msg, ...)
  -- Check if the message is a string and if it contains the specific warning text.
  -- The `find` function with `plain = true` (the last argument) does a simple text search.
  if type(msg) == "string" and string.find(msg, warning_to_silence, 1, true) then
    return -- Do nothing, effectively silencing this specific notification.
  end

  -- For any other message, call the original vim.notify function with all its original arguments.
  return original_notify(msg, ...)
end

opt.relativenumber = true
opt.number = true
opt.fileformats = { "unix", "dos" }

-- tabs & indentation
opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
opt.shiftwidth = 2 -- 2 spaces for indent width
opt.expandtab = true -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching using lowercase letter
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true

-- turn on termguicolors for tokyonight colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
-- opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text does't shift

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

-- allow fold mark
opt.foldmethod = "marker"
opt.foldlevel = 0
opt.foldlevelstart = 0

-- undo tree
opt.undofile = true
opt.undodir = vim.fn.expand("~/.config/nvim-undo")
opt.undolevels = 10000
opt.undoreload = 10000

-- vim.lsp.set_log_level("debug")

--[[ opt.pumblend = 0
opt.winblend = 0 ]]

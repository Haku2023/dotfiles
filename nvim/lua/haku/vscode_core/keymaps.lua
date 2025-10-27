local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- remap leader key
keymap("n", "<Space>", "", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- better indent handling
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- move text up and down
keymap("v", "J", ":m .+1<CR>==", opts)
keymap("v", "K", ":m .-2<CR>==", opts)
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)

-- paste preserves primal yanked piece
keymap("v", "p", '"_dP', opts)

-- removes highlighting after escaping vim search
keymap("n", "<Esc>", "<Esc>:noh<CR>", opts)

-- call vscode commands from neovim

-- general keymaps
keymap({ "n", "v" }, "<leader>t", "<cmd>lua require('vscode').action('workbench.action.terminal.toggleTerminal')<CR>")
keymap({ "n", "v" }, "<leader>b", "<cmd>lua require('vscode').action('editor.debug.action.toggleBreakpoint')<CR>")
-- keymap({ "n", "v" }, "<leader>d", "<cmd>lua require('vscode').action('editor.action.showHover')<CR>")
keymap({ "n", "v" }, "<leader>a", "<cmd>lua require('vscode').action('editor.action.quickFix')<CR>")
keymap({ "n", "v" }, "<leader>sp", "<cmd>lua require('vscode').action('workbench.actions.view.problems')<CR>")
keymap({ "n", "v" }, "<leader>cn", "<cmd>lua require('vscode').action('notifications.clearAll')<CR>")
keymap({ "n", "v" }, "<leader>ff", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
keymap({ "n", "v" }, "<leader>cp", "<cmd>lua require('vscode').action('workbench.action.showCommands')<CR>")
keymap({ "n", "v" }, "<leader>pr", "<cmd>lua require('vscode').action('code-runner.run')<CR>")
keymap({ "n", "v" }, "<leader>fd", "<cmd>lua require('vscode').action('editor.action.formatDocument')<CR>")

-- haku
-- navigation
-- keymap("n", "H", "<nop>")
-- keymap("n", "L", "<nop>")
keymap({ "n", "v" }, "<leader>j", "<cmd>>lua require('vscode').action('workbench.action.focusBelowGroup')<CR>")
-- comment
keymap({ "n", "v" }, "<leader>/", "<cmd>lua require('vscode').action('editor.action.commentLine')<CR>")
-- bookmarks
keymap({ "n", "v" }, "<leader>mm", "<cmd>lua require('vscode').action('bookmarks.toggle')<CR>")
keymap({ "n", "v" }, "<leader>m,", "<cmd>lua require('vscode').action('bookmarks.jumpToPrevious')<CR>")
keymap({ "n", "v" }, "<leader>m.", "<cmd>lua require('vscode').action('bookmarks.jumpToNext')<CR>")
keymap({ "n", "v" }, "<leader>mc", "<cmd>lua require('vscode').action('bookmarks.clear')<CR>")
keymap({ "n", "v" }, "<leader>mC", "<cmd>lua require('vscode').action('bookmarks.clearFromAllFiles')<CR>")
keymap({ "n", "v" }, "<leader>ml", "<cmd>lua require('vscode').action('bookmarks.list')<CR>")
keymap({ "n", "v" }, "<leader>mL", "<cmd>lua require('vscode').action('bookmarks.listFromAllFiles')<CR>")
-- fileexplorer
keymap({ "n", "v" }, "<leader>ee", "<cmd>lua require('vscode').action('workbench.explorer.fileView.focus')<CR>")
-- filesearch
keymap({ "n", "v" }, "<leader>ff", "<cmd>lua require('vscode').action('workbench.action.quickOpen')<CR>")
keymap({ "n", "v" }, "<leader>fg", "<cmd>lua require('vscode').action('workbench.action.quickTextSearch')<CR>")
-- indent outdent
keymap({ "n", "v" }, "<<", "<cmd>lua require('vscode').action('editor.action.outdentLines')<CR>")
keymap({ "n", "v" }, ">>", "<cmd>lua require('vscode').action('editor.action.indentLines')<CR>")

-- harpoon keymaps
-- fold <<<{{{
keymap({ "n", "v" }, "<leader>a", "<cmd>lua require('vscode').action('vscode-harpoon.addEditor')<CR>")
keymap({ "n", "v" }, "<leader>ho", "<cmd>lua require('vscode').action('vscode-harpoon.editorQuickPick')<CR>")
keymap({ "n", "v" }, "<leader>he", "<cmd>lua require('vscode').action('vscode-harpoon.editEditors')<CR>")
keymap({ "n", "v" }, "<leader>h1", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor1')<CR>")
keymap({ "n", "v" }, "<leader>h2", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor2')<CR>")
keymap({ "n", "v" }, "<leader>h3", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor3')<CR>")
keymap({ "n", "v" }, "<leader>h4", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor4')<CR>")
keymap({ "n", "v" }, "<leader>h5", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor5')<CR>")
keymap({ "n", "v" }, "<leader>h6", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor6')<CR>")
keymap({ "n", "v" }, "<leader>h7", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor7')<CR>")
keymap({ "n", "v" }, "<leader>h8", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor8')<CR>")
keymap({ "n", "v" }, "<leader>h9", "<cmd>lua require('vscode').action('vscode-harpoon.gotoEditor9')<CR>")
-- fold <<<}}}

-- project manager keymaps
keymap({ "n", "v" }, "<leader>pa", "<cmd>lua require('vscode').action('projectManager.saveProject')<CR>")
keymap({ "n", "v" }, "<leader>po", "<cmd>lua require('vscode').action('projectManager.listProjectsNewWindow')<CR>")
keymap({ "n", "v" }, "<leader>pe", "<cmd>lua require('vscode').action('projectManager.editProjects')<CR>")

-- gj/gk for nvim
-- keymap("n", "j", "gj", { noremap = false, silent = true })
-- keymap("n", "k", "gk", { noremap = false, silent = true })
-- -- cursorMove for vscode
-- keymap({ "n", "x" }, "<C-d>", function()
--   vim.fn.VSCodeNotify("cursorMove", { to = "down", by = "wrappedLine", value = 20 })
-- end, { silent = true })
-- keymap({ "n", "x" }, "<C-u>", function()
--   vim.fn.VSCodeNotify("cursorMove", { to = "up", by = "wrappedLine", value = 20 })
-- end, { silent = true })
local function map(mode, lhs, command, args)
  keymap(mode, lhs, function()
    if args then
      vim.fn.VSCodeNotify(command, args)
    else
      vim.fn.VSCodeNotify(command)
    end
  end, { silent = true, noremap = true })
end

-- gj / gk move for nvim
vim.api.nvim_set_keymap("n", "j", "gj", { noremap = false, silent = true })
vim.api.nvim_set_keymap("n", "k", "gk", { noremap = false, silent = true })
vim.api.nvim_set_keymap("n", "<C-d>", "20gj", { noremap = false, silent = true })
vim.api.nvim_set_keymap("n", "<C-u>", "20gk", { noremap = false, silent = true })
-- keymap("n", "j", "gj", { noremap = true, silent = true })
-- keymap("n", "k", "gk", { noremap = true, silent = true })
-- cursorMove for vscode
-- map({ "n", "v" }, "<C-d>", "cursorMove", { to = "down", by = "wrappedLine", value = 20 })
-- map({ "n", "v" }, "<C-u>", "cursorMove", { to = "up", by = "wrappedLine", value = 20 })
-- Remap folding keys
map("n", "zM", "editor.foldAll")
map("n", "zR", "editor.unfoldAll")
map("n", "zc", "editor.fold")
map("n", "zC", "editor.foldRecursively")
map("n", "zo", "editor.unfold")
map("n", "zO", "editor.unfoldRecursively")
map("n", "za", "editor.toggleFold")

-- in some lua file you source (e.g. lua/keymaps/vscode.lua)
-- local function move_wrapped(dir)
--   -- allow counts: 3<C-d> moves 3x the step
--   local step = (vim.g.vscode_halfpage or 20) * (vim.v.count1 or 1)
--   vim.fn.VSCodeNotify("cursorMove", { to = dir, by = "wrappedLine", value = step })
-- Optional: keep the cursor roughly centered after moving
-- vim.fn.VSCodeNotify("revealLine", { lineNumber = vim.fn.line("."), at = "center" })
-- end

-- Half-page style motions using wrapped lines (plays nice with folds)
-- vim.keymap.set({ "n", "x" }, "<C-d>", function()
--   move_wrapped("down")
-- end, { silent = true })
-- vim.keymap.set({ "n", "x" }, "<C-u>", function()
--   move_wrapped("up")
-- end, { silent = true })

-- Optional: tweak the base step without editing mappings
-- :lua vim.g.vscode_halfpage = 15

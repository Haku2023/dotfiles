vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with kk" })
keymap.set("i", "jk", "<ESC>:w<CR>", { desc = "Exit insert mode and save with jk" })
keymap.set({ "n", "x" }, "wq", ":wq<CR>", { desc = "Save and quit" })
keymap.set({ "n", "x" }, "qq", ":q!<CR>", { desc = "Save and quit" })
keymap.set({ "n", "x" }, "wa", ":wqa<CR>", { desc = "Save all and quit" })
keymap.set("x", "s", "<ESC>", { desc = "Exit visual mode with s" })
keymap.set("i", "<C-f>", "<Right>", { desc = "forward in insertmode" })
keymap.set("i", "<C-b>", "<Left>", { desc = "backward in insertmode" })
keymap.set("i", "hh", "<C-w>", { desc = "delete words in insertmode" })
keymap.set({ "n" }, "<C-t>", ":set wrap<CR>", { desc = "wrap the lines" })
keymap.set({ "i" }, "<C-t>", "<ESC>:set wrap<CR>", { desc = "wrap the lines" })

--From dycw/dotfiles
-- global marks
--[[ local prefixes = "m'"
local letters = "abcdefghijklmnopqrstuvwxyz"
for i = 1, #prefixes do
  local prefix = prefixes:sub(i, i)
  for j = 1, #letters do
    local lower_letter = letters:sub(j, j)
    local upper_letter = string.upper(lower_letter)
    keymap.set({ "n", "v" }, prefix .. lower_letter, prefix .. upper_letter, { desc = "Mark " .. upper_letter })
  end
end ]]
-- save
keymap.set({ "n", "v" }, "<C-s>", "<Cmd>w<CR>", { desc = "save" })
keymap.set("i", "<C-s>", "<ESC><Cmd>w<CR>a", { desc = "save" })
-- no highlight
keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear Highlights" })
-- no highlight
keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear Highlights" })
-- paste in insertion
keymap.set("i", "<C-v>", "<C-o>p", { desc = "Paste in insert mode" })
-- quickfix
-- keymap.set("n", "]", "<Cmd>cnext<CR>", "Quickfix next")
-- keymap.set("n", "[", "<Cmd>cprev<CR>", "Quickfix prev")
--From dycw/dotfiles

-- inspect
keymap.set("n", "<leader>i", "<Cmd>Inspect<CR>", { desc = "Clear All Marks a-z A-Z 0-9" })
-- marks
keymap.set("n", "<leader>md", "<Cmd>delmarks a-z A-Z 0-9<CR>", { desc = "Clear All Marks a-z A-Z 0-9" })
--inspect
keymap.set("n", "<leader>i", "<Cmd>Inspect<CR>", { desc = "Inspect in Treesitter" })
-- show full path
keymap.set("n", "<C-g>", ":echo expand('%:p')<CR>", { desc = "show full path" })
-- Lazy and Mason
keymap.set("n", "<leader>ll", ":Lazy<CR>", { desc = "open lazy" })
keymap.set("n", "<leader>lm", ":Mason<CR>", { desc = "open mason" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) --  decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make split equal size" })
keymap.set("n", "<leader>sw", "<Cmd>close<CR>", { desc = "Close current split" })

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tw", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>=", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<Cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<Cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

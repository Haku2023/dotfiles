vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

-- keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with kk" })
keymap.set("i", "jk", "<ESC>:w<CR>", { desc = "Exit insert mode and save with jk" })
keymap.set({ "n", "x" }, "wq", "<cmd>wq<CR>", { desc = "Save and quit" })
keymap.set({ "n", "x" }, "qq", "<cmd>q!<CR>", { desc = "Save and quit" })
keymap.set({ "n", "x" }, "wa", "<cmd>wqa<CR>", { desc = "Save all and quit" })
keymap.set("x", "s", "<ESC>", { desc = "Exit visual mode with s" })
keymap.set("i", "<C-f>", "<Right>", { desc = "forward in insertmode" })
keymap.set("i", "<C-b>", "<Left>", { desc = "backward in insertmode" })
keymap.set("i", "hh", "<C-w>", { desc = "delete words in insertmode" })
keymap.set({ "n" }, "<C-t>", "<cmd>set wrap<CR>", { desc = "wrap the lines" })
keymap.set({ "i" }, "<C-t>", "<ESC>:set wrap<CR>", { desc = "wrap the lines" })
-- commandline mode
keymap.set("c", "<C-A>", "<HOME>")
keymap.set("c", "<C-F>", "<Right>")
keymap.set("c", "<C-B>", "<Left>")
keymap.set("c", "<C-D>", "<C-W>")

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
keymap.set("n", "<leader>kd", "<Cmd>delmarks a-z A-Z 0-9<CR>", { desc = "Clear All Marks a-z A-Z 0-9" })
--inspect
keymap.set("n", "<leader>i", "<Cmd>Inspect<CR>", { desc = "Inspect in Treesitter" })
-- show full path
keymap.set("n", "<C-g>", ":echo expand('%:p')<CR>", { desc = "show full path" })
-- Lazy and Mason
keymap.set("n", "<leader>;l", "<Cmd>Lazy<CR>", { desc = "open lazy" })
keymap.set("n", "<leader>;m", "<Cmd>Mason<CR>", { desc = "open mason" })
-- Yank content, filepath
keymap.set("n", "<leader>yy", "<Cmd>%y+<CR>", { desc = "yank entire file content" })
keymap.set("n", "<leader>yf", "<Cmd>let @+ = expand('%:t')<CR>", { desc = "yank filename" })
keymap.set("n", "<leader>ya", "<Cmd>let @+ = expand('%:p')<CR>", { desc = "yank absolute path" })
keymap.set("n", "<leader>yr", "<Cmd>let @+ = expand('%')<CR>", { desc = "yank relative path" })
keymap.set("n", "<leader>yd", "<Cmd>let @+ = expand('%:h')<CR>", { desc = "yank directory" })

keymap.set("n", "<leader>nh", "<Cmd>nohl<CR>", { desc = "Clear search highlights" })

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

-- Dismiss Noice Message
keymap.set("n", "<leader>nd", "<cmd>NoiceDismiss<CR>", { desc = "Dismiss Noice Message" })
keymap.set("n", "<leader>nt", "<cmd>Noice telescope<CR>", { desc = "Telescope Noice Message" })
keymap.set("n", "<leader>na", "<cmd>NoiceAll<CR>", { desc = "Noice All" })

-- Toggleterm
keymap.set({ "n", "t" }, "<leader>\\", "<cmd>ToggleTerm direction=float<cr>", { desc = "ToggleTerm float" })
keymap.set({ "n", "t" }, "<leader>\\s", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "ToggleTerm float" })
keymap.set({ "n", "t" }, "<leader>\\v", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "ToggleTerm float" })

-- Open CodeCompanion chat
vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat<cr>", { desc = "Open CodeCompanion chat" })

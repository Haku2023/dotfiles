vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>:w<CR>", { desc = "Exit insert mode with jj" })
keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with kk" })
keymap.set({ "n", "x" }, "qw", ":wq<CR>", { desc = "Save and quit" })
keymap.set({ "n", "x" }, "qe", ":wqa<CR>", { desc = "Save all and quit" })
keymap.set("x", "s", "<ESC>", { desc = "Exit visual mode with s" })
keymap.set("i", "<C-f>", "<Right>", { desc = "forward in insertmode" })
keymap.set("i", "<C-b>", "<Left>", { desc = "backward in insertmode" })
keymap.set({ "n", "i" }, "<C-t>", ":set wrap<CR>", { desc = "wrap the lines" })

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

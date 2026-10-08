vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local keymap = vim.keymap -- for conciseness

-- keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with kk" })
-- keymap.set("i", "jk", "<ESC>:w<CR>", { desc = "Exit insert mode and save with jk" })
-- function to hide CodeCompanion and ToggleTerm panels and quit Neovim
--{{{
local function hide_panels_and_quit(save)
  local api = vim.api
  local editor_win = api.nvim_get_current_win()
  local tab = api.nvim_get_current_tabpage()
  local current_buf = api.nvim_win_get_buf(editor_win)

  -- Count ordinary splits, excluding terminals and CodeCompanion chats.
  -- Maximizer's floating covers are excluded automatically.
  local pane_count = 0
  for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
    local buf = api.nvim_win_get_buf(win)
    local config = api.nvim_win_get_config(win)

    if
      config.relative == ""
      and not config.external
      and vim.bo[buf].buftype ~= "terminal"
      and vim.bo[buf].filetype ~= "codecompanion"
    then
      pane_count = pane_count + 1
    end
  end

  -- Write editing buffers only; tool panes such as quickfix are not files.
  -- If writing fails, leave the layout intact.
  if save and vim.bo[current_buf].buftype == "" then
    vim.cmd("write")
  end

  -- With extra panes open, close only the current window.
  local current_config = api.nvim_win_get_config(editor_win)
  if pane_count > 1 or current_config.relative ~= "" then
    vim.cmd(save and "close" or "close!")
    return
  end

  -- Hide visible CodeCompanion chats in this tab.
  local cc = package.loaded["codecompanion"]
  if cc then
    for _, win in ipairs(api.nvim_tabpage_list_wins(tab)) do
      if win ~= editor_win and api.nvim_win_is_valid(win) then
        local chat = cc.buf_get_chat(api.nvim_win_get_buf(win))
        if chat then
          chat.ui:hide()
        end
      end
    end
  end

  -- Hide visible ToggleTerm terminals in this tab.
  local terminals = package.loaded["toggleterm.terminal"]
  if terminals then
    for _, term in pairs(terminals.get_all(true)) do
      if
        term.window
        and term.window ~= editor_win
        and api.nvim_win_is_valid(term.window)
        and api.nvim_win_get_tabpage(term.window) == tab
      then
        term:close()
      end
    end
  end

  if api.nvim_win_is_valid(editor_win) then
    api.nvim_set_current_win(editor_win)
    vim.cmd(save and "quit" or "quit!")
  end
end
--}}}

keymap.set({ "n", "x" }, "wq", function()
  hide_panels_and_quit(true)
end, { desc = "Save, hide panels, and quit" })

keymap.set({ "n", "x" }, "qq", function()
  hide_panels_and_quit(false)
end, { desc = "Hide panels and quit without saving" })
-- keymap.set({ "n", "x" }, "wq", "<cmd>wq<CR>", { desc = "Save and quit" })
-- keymap.set({ "n", "x" }, "qq", "<cmd>q!<CR>", { desc = "quit without save" })
local save_session_and_quit = function(input)
  return function()
    -- Close the DAP UI first so its windows aren't captured in the session.
    local ok, dapui = pcall(require, "dapui")
    if ok then
      pcall(dapui.close)
    end
    pcall(vim.cmd, "AutoSession save")
    vim.cmd(input)
  end
end
-- keymap.set({ "n", "x" }, "wa", save_session_and_quit("wqa!"), { desc = "Save all and quit" })
-- keymap.set({ "n", "x" }, "qa", save_session_and_quit("qa!"), { desc = "Save session and quit all" })
keymap.set({ "n", "x" }, "wa", "<cmd>wqa<CR>", { desc = "Save all and quit" })
keymap.set({ "n", "x" }, "qa", "<cmd>qa<CR>", { desc = "Save session and quit all" })
-- keymap.set({ "n", "x" }, "<leader>qa", save_session_and_quit("qa!"), { desc = "Save session and quit all" })
keymap.set("x", "s", "<ESC>", { desc = "Exit visual mode with s" })
keymap.set("i", "<C-f>", "<Right>", { desc = "forward in insertmode" })
keymap.set("i", "<C-b>", "<Left>", { desc = "backward in insertmode" })
-- keymap.set("i", "hh", "<C-h>", { desc = "delete character in insertmode" })
-- keymap.set("i", "ff", "<Right>", { desc = "forward character in insertmode" })
keymap.set("i", "jj", "<End><CR>", { desc = "forward character in insertmode" })
-- keymap.set("i", "uu", "_", { desc = "forward character in insertmode" })
keymap.set({ "n", "x" }, "<leader>cc", "<cmd>e<CR>", { desc = "reload buffer" })
keymap.set({ "n", "x" }, "<leader>,", "<<", { desc = "Indent" })
keymap.set({ "n", "x" }, "<leader>.", ">>", { desc = "Unindent" })

-- window resize
keymap.set("n", "<leader>wl", "2<C-w><", { desc = "Resize window left" })
keymap.set("n", "<leader>wh", "2<C-w>>", { desc = "Resize window right" })
keymap.set("n", "<leader>wk", "2<C-w>+", { desc = "Resize window up" })
keymap.set("n", "<leader>wj", "2<C-w>-", { desc = "Resize window down" })
-- keymap.set({ "n" }, "<C-t>", "<cmd>set wrap<CR>", { desc = "wrap the lines" })
-- keymap.set({ "i" }, "<C-t>", "<ESC>:set wrap<CR>", { desc = "wrap the lines" })
keymap.set({ "i", "n" }, "<C-t>", function()
  if vim.g.word_wrap == nil or vim.g.word_wrap == 0 then
    vim.cmd("set wrap")
    vim.g.word_wrap = 1
    print("Set Word Wrap!")
  else
    vim.cmd("set nowrap")
    vim.g.word_wrap = 0
    print("Unset Word Wrap!")
  end
end, { desc = "Toogle word wrap!" })
-- commandline mode
keymap.set("c", "<C-A>", "<HOME>")
keymap.set("c", "<C-F>", "<Right>")
keymap.set("c", "<C-B>", "<Left>")
keymap.set("c", "<C-D>", "<C-W>")
keymap.set("c", "<C-v>", "<C-R>+")
keymap.set("c", "<C-k>", "<C-\\>e(strpart(getcmdline(), 0, getcmdpos()-1))<CR>")

-- system settings
keymap.set("n", "<leader>sf", "<Cmd>luafile %<CR>", { desc = "Source current lua file" })
keymap.set("n", "<leader>sr", function()
  for module, _ in pairs(package.loaded) do
    if module == "haku" or module:match("^haku%.") then
      package.loaded[module] = nil
    end
  end

  require("haku.core")
  require("lazy.manage.reloader").reload({
    { file = vim.fn.stdpath("config"), what = "manual reload" },
  })

  vim.notify("Reloaded Neovim config", vim.log.levels.INFO, { title = "Neovim" })
end, { desc = "Reload Neovim config" })
keymap.set("n", "[z", "zk", { desc = "Jump to next fold" })
keymap.set("n", "]z", "zj", { desc = "jump to previous fold" })

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
-- keymap.set("n", "<C-g>", "<Cmd>echo expand('%:p')<CR>", { desc = "show full path" })
keymap.set("n", "<C-g>", function()
  vim.notify(vim.fn.expand("%:p"), vim.log.levels.INFO, { title = "Full path" })
end, { desc = "show full path" })
keymap.set("n", "<leader>gf", function()
  vim.notify(vim.fn.expand("%:t"), vim.log.levels.INFO, { title = "File name" })
end, { desc = "show file name" })
keymap.set("n", "<leader>gd", function()
  vim.notify(vim.fn.expand("%:p:h"), vim.log.levels.INFO, { title = "Dir name" })
end, { desc = "show dir name" })
-- Lazy and Mason
keymap.set("n", "<leader>;l", "<Cmd>Lazy<CR>", { desc = "open lazy" })
keymap.set("n", "<leader>;m", "<Cmd>Mason<CR>", { desc = "open mason" })
-- Yank content, filepath
keymap.set("n", "<leader>yy", "<Cmd>%y+<CR>", { desc = "yank entire file content" })
keymap.set("n", "<leader>yf", "<Cmd>let @+ = expand('%:t')<CR>", { desc = "yank filename" })
keymap.set("n", "<leader>ya", "<Cmd>let @+ = expand('%:p')<CR>", { desc = "yank absolute path" })
keymap.set("n", "<leader>yr", "<Cmd>let @+ = expand('%')<CR>", { desc = "yank relative path" })
keymap.set("n", "<leader>yd", "<Cmd>let @+ = expand('%:p:h')<CR>", { desc = "yank directory" })

keymap.set("n", "<leader>nh", "<Cmd>nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) --  decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make split equal size" })
keymap.set("n", "<leader>sw", "<Cmd>close<CR>", { desc = "Close current split" })
-- keymap.set("n", "<leader>ss", [[:%s/\r//g<CR><C-o>]], { desc = "Strip ^M" })
vim.keymap.set("n", "<leader>ss", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keepjumps keeppatterns silent! %s/\r//g]])
  vim.fn.winrestview(view)
end, { desc = "Trim/Strip ^M" })

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
keymap.set({ "n", "t" }, "<leader>jf", "<cmd>ToggleTerm direction=float<cr>", { desc = "ToggleTerm float" })
keymap.set({ "n", "t" }, "<leader>jj", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "ToggleTerm float" })
keymap.set({ "n", "t" }, "<leader>jk", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "ToggleTerm float" })
vim.keymap.set("n", "<leader>jh", "<Cmd>2ToggleTerm direction=vertical<CR>", { desc = "Terminal #2" })
vim.keymap.set("n", "<leader>jv", "<Cmd>2ToggleTerm direction=horizontal<CR>", { desc = "Terminal #2" })

-- Open CodeCompanion chat
vim.keymap.set("n", "<leader>a", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion chat" })
vim.keymap.set(
  { "v" },
  "<leader>ga",
  "<cmd>CodeCompanionChat Add<cr>",
  { desc = "add visually selected chat to current chat buffer" }
)
keymap.set("n", "<leader>co", function()
  require("codecompanion").chat({ adapter = "claude_code" })
end, { desc = "CodeCompanion with Opus" })

keymap.set("n", "<leader>cx", function()
  require("codecompanion").chat({ adapter = "codex" })
end, { desc = "CodeCompanion with Codex" })
-- vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat<cr>", { desc = "Open CodeCompanion chat" })

-- remap * and # to search for the word under the cursor without moving the cursor
vim.keymap.set("n", "*", "mz*`z", { desc = "Search word, stay put" })
vim.keymap.set("n", "#", "mz#`z", { desc = "Search word backward, stay put" })
vim.keymap.set("n", "<leader>hi", "<cmd>Inspect<cr>", { desc = "Inspect highlight under cursor" })
vim.keymap.set("n", "<C-n>", "<C-^>", { desc = "Switch to previous file" })

-- remap folding
keymap.set("n", "zc", "zm", { desc = "close all fold" })
keymap.set("n", "zo", "zr", { desc = "open all fold" })

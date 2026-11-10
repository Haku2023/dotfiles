return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    local function default_size(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.4)
      end
    end

    local function reset_size(term)
      if not term.window or not vim.api.nvim_win_is_valid(term.window) then
        return
      end

      local size = default_size(term)
      if term.direction == "horizontal" and size then
        vim.api.nvim_win_set_height(term.window, size)
      elseif term.direction == "vertical" and size then
        vim.api.nvim_win_set_width(term.window, size)
      end
    end

    require("toggleterm").setup({
      size = default_size,
      on_open = function(term)
        vim.schedule(function()
          reset_size(term)
        end)
      end,
      -- When the terminal closes, restore layout only if a *non-terminal*
      -- window was maximized, so subsequent <leader>sm works correctly.
      -- on_close = function(term)
      --   if vim.g.maximizer_set and vim.g.maximizer_winid ~= term.window then
      --     vim.cmd("MaximizerToggle")
      --   elseif vim.g.maximizer_set and vim.g.maximizer_winid == term.window then
      --     vim.g.maximizer_set = false
      --   end
      -- end,
    })

    -- NOTE: <C-\\> (double backslash) is the correct key notation in Lua
    --
    -- function _G.set_terminal_keymaps()
    --   local opts = { buffer = 0 }
    --
    --   -- exit terminal-mode to normal-mode
    --   vim.keymap.set("t", "<esc>", [[<C-\\><C-n>]], opts)
    --   vim.keymap.set("t", "jk", [[<C-\\><C-n>]], opts)
    --
    --   -- window navigation while in terminal-mode
    --   vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
    --   vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
    --   vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
    --   vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
    --
    --   -- terminal equivalent of <C-w>...
    --   vim.keymap.set("t", "<C-w>", [[<C-\\><C-n><C-w>]], opts)
    -- end
    --
    -- -- Apply ONLY to toggleterm terminals (recommended)
    -- vim.api.nvim_create_autocmd("TermOpen", {
    --   pattern = "term://*toggleterm#*",
    --   callback = function()
    --     _G.set_terminal_keymaps()
    --   end,
    -- })
    --
    function _G.set_terminal_keymaps()
      local opts = { buffer = 0 }

      -- ESC → leave terminal-mode
      vim.keymap.set("t", "<Esc>", function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
      end, opts)

      -- Shell command editing in terminal input mode
      vim.keymap.set("t", "<C-d>", "<Del>", opts)
      vim.keymap.set("t", "<M-b>", "<C-Left>", opts)
      vim.keymap.set("t", "<M-f>", "<C-Right>", opts)
      vim.keymap.set("t", "<M-h>", "<C-w>", opts)

      -- jk → leave terminal-mode
      vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)

      -- window navigation
      -- vim.keymap.set("t", "<C-h>", "<Cmd>wincmd h<CR>", opts)
      vim.keymap.set("t", "<C-j>", "<Cmd>wincmd j<CR>", opts)
      vim.keymap.set("t", "<C-k>", "<Cmd>wincmd k<CR>", opts)
      vim.keymap.set("t", "<C-l>", "<Cmd>wincmd l<CR>", opts)

      -- <C-w> passthrough
      vim.keymap.set("t", "<C-w>", function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n><C-w>", true, false, true), "n", false)
      end, opts)
    end

    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*toggleterm#*",
      callback = function()
        _G.set_terminal_keymaps()
      end,
    })

    -- Toggleterm
    local keymap = vim.keymap
    keymap.set({ "n", "t" }, "<leader>jf", "<cmd>ToggleTerm direction=float<cr>", { desc = "ToggleTerm float" })
    -- keymap.set({ "n", "t" }, "<leader>jj", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "ToggleTerm float" })
    keymap.set({ "n", "t" }, "<leader>jk", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "ToggleTerm float" })
    -- insert horizontal terminal below current pane
    local pane_terminal
    local saved_layout
    local horizontal_layout

    local function close_pane_terminal()
      pane_terminal:close()

      if saved_layout then
        local layout = saved_layout
        saved_layout = nil

        vim.schedule(function()
          if vim.api.nvim_get_current_tabpage() == layout.tab and layout.layout == vim.inspect(vim.fn.winlayout()) then
            vim.cmd(layout.restore)
          end
        end)
      end
    end

    keymap.set({ "n", "t" }, "<leader>jj", function()
      if pane_terminal and pane_terminal:is_open() then
        close_pane_terminal()
        return
      end

      local function terminal_is_open()
        for _, term in pairs(require("toggleterm.terminal").get_all()) do
          if term:is_open() then
            return true
          end
        end
        return false
      end

      -- Save the original pane sizes before opening.
      if not terminal_is_open() then
        horizontal_layout = {
          layout = vim.inspect(vim.fn.winlayout()),
          tab = vim.api.nvim_get_current_tabpage(),
          restore = vim.fn.winrestcmd(),
        }
      end

      vim.cmd("ToggleTerm direction=horizontal")

      -- Restore the original pane sizes after closing.
      if not terminal_is_open() and horizontal_layout then
        local layout = horizontal_layout
        horizontal_layout = nil

        vim.schedule(function()
          if vim.api.nvim_get_current_tabpage() == layout.tab and layout.layout == vim.inspect(vim.fn.winlayout()) then
            vim.cmd(layout.restore)
          end
        end)
      end
    end, { desc = "Toggle horizontal terminal" })

    keymap.set({ "n", "t" }, "<leader>jx", function()
      if not pane_terminal then
        pane_terminal = require("toggleterm.terminal").Terminal:new({
          direction = "horizontal",
          hidden = true,
          on_open = function() end,
        })
      end

      if pane_terminal:is_open() then
        close_pane_terminal()
        return
      end

      local target = vim.api.nvim_get_current_win()
      local height = math.max(1, math.floor((vim.api.nvim_win_get_height(target) - 1) / 2))

      saved_layout = {
        layout = vim.inspect(vim.fn.winlayout()),
        tab = vim.api.nvim_get_current_tabpage(),
        restore = vim.fn.winrestcmd(),
      }

      -- Avoid automatically equalizing other panes during the move.
      local equalalways = vim.o.equalalways
      vim.o.equalalways = false

      local ok, err = pcall(function()
        pane_terminal:open(height)

        vim.fn.win_splitmove(pane_terminal.window, target, {
          vertical = false,
          rightbelow = true,
        })
        vim.api.nvim_set_current_win(pane_terminal.window)
        vim.api.nvim_win_set_height(pane_terminal.window, height)
      end)

      vim.o.equalalways = equalalways

      if not ok then
        error(err)
      end

      vim.cmd("startinsert")
    end, { desc = "Toggle terminal in half-height split" })
    --
    vim.keymap.set("n", "<leader>jh", "<Cmd>2ToggleTerm direction=vertical<CR>", { desc = "Terminal #2" })
    vim.keymap.set("n", "<leader>jv", "<Cmd>2ToggleTerm direction=horizontal<CR>", { desc = "Terminal #2" })
  end,
}

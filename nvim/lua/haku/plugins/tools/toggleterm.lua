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
      on_close = function(term)
        if vim.g.maximizer_set and vim.g.maximizer_winid ~= term.window then
          vim.cmd("MaximizerToggle")
        elseif vim.g.maximizer_set and vim.g.maximizer_winid == term.window then
          vim.g.maximizer_set = false
        end
      end,
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
  end,
}

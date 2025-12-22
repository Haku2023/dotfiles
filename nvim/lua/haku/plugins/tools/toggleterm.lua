return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      -- you can omit open_mapping if you prefer manual mappings
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
      vim.keymap.set("t", "jk", function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
      end, opts)

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

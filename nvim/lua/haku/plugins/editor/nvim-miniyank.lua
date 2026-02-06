return {
  {
    "bfredl/nvim-miniyank",
    -- loads on startup; you can also make it lazy-load if you want
    config = function()
      -- Optional: make it persist across reboots (README suggestion)
      -- vim.g.miniyank_filename = vim.fn.expand("~/.miniyank.mpack")

      -- Optional: more history items
      -- vim.g.miniyank_maxitems = 100

      -- Recommended mappings from the README:
      -- "autoput" replaces normal p/P but keeps register behavior
      vim.keymap.set({ "n", "x" }, "p", "<Plug>(miniyank-autoput)")
      vim.keymap.set({ "n", "x" }, "P", "<Plug>(miniyank-autoPut)")

      -- Alternative: "startput" (explicit yank-history put)
      -- vim.keymap.set({ "n", "x" }, "<leader>p", "<Plug>(miniyank-startput)")
      -- vim.keymap.set({ "n", "x" }, "<leader>P", "<Plug>(miniyank-startPut)")

      -- Cycle through yank history after putting
      vim.keymap.set({ "n", "x" }, "<leader>pn", "<Plug>(miniyank-cycle)")
      vim.keymap.set({ "n", "x" }, "<leader>pN", "<Plug>(miniyank-cycleback)")

      -- Fix register type after put (char/line/block)
      vim.keymap.set({ "n", "x" }, "<leader>pc", "<Plug>(miniyank-tochar)")
      vim.keymap.set({ "n", "x" }, "<leader>pl", "<Plug>(miniyank-toline)")
      vim.keymap.set({ "n", "x" }, "<leader>pb", "<Plug>(miniyank-toblock)")
    end,
  },
}

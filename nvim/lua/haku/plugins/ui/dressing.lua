return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  opts = {
    input = {
      get_config = function(opts)
        if vim.trim(opts.prompt or "") == "Watch:" then
          return {
            mappings = {
              i = { ["<C-a>"] = "<Home>", ["<C-e>"] = "<End>" },
              n = { ["<C-a>"] = "0" },
            },
          }
        end
      end,
    },
  },
}

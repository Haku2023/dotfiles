return {
  "folke/flash.nvim",
  event = "VeryLazy",
  -- -@type Flash.Config
  opts = {
    label = {
      after = true,
      style = "overlay",
      rainbow = { enabled = true },
    },
    modes = {
      search = {
        enabled = true,
      },
      char = {
        -- enable/disable the flash in f/t mode
        enabled = true,
        jump_labels = true,
        config = function(opts)
          -- disable jump labels when not enabled, when using a count,
          -- or when recording/executing registers
          opts.label.rainbow.enabled = opts.label.rainbow.enabled
            and vim.v.count == 0
            and vim.fn.reg_executing() == ""
            and vim.fn.reg_recording() == ""
        end,
        jump = { register = true },
      },
    },
  },
  -- stylua: ignore
  keys = {
    -- { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}

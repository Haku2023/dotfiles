return {
  -- "folke/flash.nvim",
  "Haku2023/flash.nvim",
  branch = "remote-cursor-fix",
  event = "VeryLazy",
  -- -@type Flash.Config
  opts = {
    search = {
      forward = true,
      wrap = true,
      mode = "exact",
    },
    label = {
      after = true,
      style = "overlay",
      rainbow = { enabled = true, shade = 5 },
    },
    modes = {
      search = {
        enabled = true,
      },
      char = {
        -- enable/disable the flash in f/t mode
        enabled = false,
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
    { "f", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}

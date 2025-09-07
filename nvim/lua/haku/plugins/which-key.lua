return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 5000
  end,
  --[[ vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "NONE" }),
  vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "NONE", fg = "#5E81AC" }), -- border transparent, custom color ]]
  opts = {
    -- your configurations comes here
    preset = "helix",
    -- not work
    --[[ win = {
      border = "rounded",
      wo = {
        winblend = 100,
      },
    }, ]]
    -- or leave it empty to use the default settings
    -- refer to the configurations section below
  },
  config = function(_, opts)
    require("which-key").setup(opts)
    -- which-key uses WhichKeyNormal (links to NormalFloat by default)
    -- opacity setting transparent
    vim.api.nvim_set_hl(0, "WhichKeyNormal", { bg = "#1F2335", blend = 0 })
    vim.api.nvim_set_hl(0, "WhichKeyBorder", { bg = "#1F2335", blend = 0 })
    vim.api.nvim_set_hl(0, "WhichKeyTitle", { bg = "#1F2335", blend = 0 })
  end,
}

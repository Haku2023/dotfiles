-- lazy.nvim
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    -- add any options here
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim",
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    "rcarriga/nvim-notify",
  },

  config = function(_, opts)
    require("noice").setup(opts)
    require("notify").setup({ background_colour = "#0000000" })
    require("telescope").load_extension("noice")

    vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", {
      -- bg = "#1e1e2e",
    })

    vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", {
      -- fg = "#ff79c6",
      -- bg = "#1e1e2e",
    })

    vim.api.nvim_set_hl(0, "NoiceCmdlineInput", {
      -- fg = "#ff79c6",
    })

    vim.api.nvim_set_hl(0, "NoiceCmdlinePrompt", {
      -- fg = "#89b4fa",
      -- bold = true,
    })
  end,
}

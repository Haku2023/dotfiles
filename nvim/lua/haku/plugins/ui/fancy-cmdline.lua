-- lazy.nvim
return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          any = {
            { find = "quote_from_bytes" },
            { find = "NO_RESULT_CALLBACK_FOUND" },
          },
        },
        opts = { skip = true },
      },
    },
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

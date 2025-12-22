return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      mode = "tabs",
      separator_style = "thin",
    },

    highlights = {
      fill = {
        bg = "NONE",
      },
      background = {
        bg = "NONE",
      },
    },
  },
  -- not work for transparent
  --[[ vim.keymap.set("n", "<leader>bj", "<Cmd>BufferLineCycleNext<CR>"),
  vim.keymap.set("n", "<leader>bk", "<Cmd>BufferLineCyclePrev<CR>"), ]]
}

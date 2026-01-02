return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" }, -- lazy load on markdown files
  opts = {
    latex = { enabled = true },
  },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons", -- optional, for icons
  },
}

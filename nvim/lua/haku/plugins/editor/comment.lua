return {
  "numToStr/Comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "JoosepAlviste/nvim-ts-context-commentstring",
  },
  config = function()
    -- import comment plugin safely
    local comment = require("Comment")

    local ts_context_commentstring = require("ts_context_commentstring.integrations.comment_nvim")

    -- Set commentstring for namelist files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "namelist",
      callback = function()
        vim.bo.commentstring = "! %s"
      end,
    })

    -- enable comment
    comment.setup({
      -- for commenting tsx, jsx, svelte, html files
      pre_hook = ts_context_commentstring.create_pre_hook(),
      toggler = {
        line = "<leader>/",
        -- block = '<leader>bc',
      },
      opleader = {
        line = "<leader>/",
        -- block = '<leader>b',
      },
    })
  end,
}

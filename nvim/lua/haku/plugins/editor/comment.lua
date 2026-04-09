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

    -- Set commentstring for autohotkey files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "autohotkey", "ahk" },
      callback = function()
        vim.bo.commentstring = "; %s"
      end,
    })
    -- enable comment
    -- comment.setup({
    --   -- for commenting tsx, jsx, svelte, html files
    --   pre_hook = ts_context_commentstring.create_pre_hook(),
    --   toggler = {
    --     line = "<leader>/",
    --     -- block = '<leader>bc',
    --   },
    --   opleader = {
    --     line = "<leader>/",
    --     -- block = '<leader>b',
    --   },
    -- })

    -- comment.setup({
    --   pre_hook = function(ctx)
    --     local ft = vim.bo.filetype
    --     -- if ft == "namelist" then
    --     --   return nil
    --     -- end
    --
    --     if ft == "namelist" or ft == "autohotkey" or ft == "ahk" then
    --       return nil
    --     end
    --     return ts_context_commentstring.create_pre_hook()(ctx)
    --   end,
    --   toggler = {
    --     line = "<leader>/",
    --   },
    --   opleader = {
    --     line = "<leader>/",
    --   },
    -- })

    local ts_pre_hook = ts_context_commentstring.create_pre_hook()

    comment.setup({
      pre_hook = function(ctx)
        local ft = vim.bo.filetype

        if ft == "namelist" or ft == "autohotkey" or ft == "ahk" then
          return vim.bo.commentstring
        end

        local ok, cstr = pcall(ts_pre_hook, ctx)
        return ok and cstr or vim.bo.commentstring
      end,
      toggler = {
        line = "<leader>/",
      },
      opleader = {
        line = "<leader>/",
      },
    })
  end,
}

return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        fortran = { "fprettify" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        liquid = { "prettier" },
        lua = { "stylua" },
        python = { "black" },
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
      format_on_save = function(bufnr)
        -- Disable for markdown
        if vim.bo[bufnr].filetype == "markdown" then
          return
        end

        return {
          lsp_fallback = true,
          async = false,
          timeout_ms = 3000,
        }
      end,
      -- format_on_save = {
      --   lsp_fallback = true,
      --   async = false,
      --   timeout_ms = 3000,
      -- },
    })

    conform.formatters.fprettify = { append_args = { "--indent", "4" } }

    vim.keymap.set({ "n", "v" }, "<leader>kp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}

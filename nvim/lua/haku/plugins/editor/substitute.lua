return {
  "gbprod/substitute.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local substitute = require("substitute")

    substitute.setup({
      highlight_substituted_text = {
        enabled = true,
        timer = 1000,
      },
    })

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    vim.keymap.set("n", "r", substitute.operator, { desc = "Substitute with motion" })
    vim.keymap.set("n", "rr", substitute.line, { desc = "Substitute line" })
    vim.keymap.set("n", "R", substitute.eol, { desc = "Substitute to end of line" })
    vim.keymap.set("x", "r", substitute.visual, { desc = "Substitute in visual mode" })
  end,
}

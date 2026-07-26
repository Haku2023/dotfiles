return {
  "folke/todo-comments.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local todo_comments = require("todo-comments")

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set("n", "]t", function()
      todo_comments.jump_next()
    end, { desc = "Next todo comment" })

    keymap.set("n", "[t", function()
      todo_comments.jump_prev()
    end, { desc = "Previous todo comment" })

    -- Open a new line above (like `O`) with a filetype-aware TEST comment,
    -- e.g. "!TEST: " in Fortran, "--TEST: " in Lua, "#TEST: " in Python.
    keymap.set("n", "<leader>'", function()
      local cs = vim.bo.commentstring
      if cs == nil or cs == "" then
        cs = "# %s"
      end
      -- split commentstring around the %s placeholder
      local left, right = cs:match("^(.*)%%s(.*)$")
      if not left then
        left, right = cs, ""
      end
      -- drop the trailing space so Fortran yields "!TEST:" not "! TEST:"
      left = left:gsub("%s+$", "")

      local row = vim.api.nvim_win_get_cursor(0)[1]
      local indent = vim.api.nvim_get_current_line():match("^%s*") or ""
      local text = indent .. left .. "TEST:" .. right

      -- insert the comment on a new line above the current line
      vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { text })
      -- park the cursor on the new line, just after "TEST: "
      vim.api.nvim_win_set_cursor(0, { row, #(indent .. left .. "TEST:") })
    end, { desc = "Add TEST comment line above" })

    todo_comments.setup({
      -- custom keywords are merged with the defaults (merge_keywords = true by default)
      keywords = {
        ERROR = { icon = " ", color = "error", alt = { "ERR" } },
        -- override a default: give TODO a different icon
        -- TODO = { icon = " ", color = "info" },
      },
    })
  end,
}

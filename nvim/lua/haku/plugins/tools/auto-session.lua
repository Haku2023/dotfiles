return {
  "rmagatti/auto-session",
  dependencies = { "goolord/alpha-nvim" },
  lazy = false,
  config = function()
    local auto_session = require("auto-session")
    local function show_alpha_if_empty()
      local buf = vim.api.nvim_get_current_buf()

      if
        vim.bo[buf].filetype == "alpha"
        or vim.bo[buf].buftype ~= ""
        or vim.bo[buf].modified
        or vim.api.nvim_buf_get_name(buf) ~= ""
        or vim.api.nvim_buf_line_count(buf) ~= 1
        or vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] ~= ""
      then
        return
      end

      require("alpha").start()
    end

    auto_session.setup({
      auto_save = false,
      auto_restore = true,
      args_allow_single_directory = true,
      suppressed_dirs = { "~/", "~/Downloads", "~/Documents", "~/Desktop/", "~/dotfiles/", "~/haku_posts/" },
      bypass_save_filetypes = { "alpha" },
      no_restore_cmds = { show_alpha_if_empty },
      post_restore_cmds = { show_alpha_if_empty },
    })

    local keymap = vim.keymap

    keymap.set("n", "<leader>wr", "<cmd>AutoSession restore<CR>", { desc = "Restore session for cwd" })
    keymap.set("n", "<leader>ws", "<cmd>AutoSession save<CR>", { desc = "Save session for auto session root dir" })
    keymap.set("n", "<leader>wd", "<cmd>AutoSession delete<CR>", { desc = "Save session for auto session root dir" })
  end,
}

return {
  "rmagatti/auto-session",
  lazy = false,
  config = function()
    local auto_session = require("auto-session")

    auto_session.setup({
      auto_save = false,
      auto_restore = true,
      args_allow_single_directory = true,
      suppressed_dirs = { "~/", "~/Downloads", "~/Documents", "~/Desktop/", "~/dotfiles/", "~/haku_posts/" },
      bypass_save_filetypes = { "alpha" },
    })

    local keymap = vim.keymap

    keymap.set("n", "<leader>wr", "<cmd>AutoSession restore<CR>", { desc = "Restore session for cwd" })
    keymap.set("n", "<leader>ws", "<cmd>AutoSession save<CR>", { desc = "Save session for auto session root dir" })
  end,
}

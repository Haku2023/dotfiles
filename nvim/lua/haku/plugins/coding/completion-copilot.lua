return {
  "github/copilot.vim",
  config = function()
    -- Toggle Copilot suggestions
    vim.keymap.set("n", "<leader>ct", function()
      if vim.g.copilot_enabled == nil or vim.g.copilot_enabled == 1 then
        vim.cmd("Copilot disable")
        vim.g.copilot_enabled = 0
        print("Copilot disabled")
      else
        vim.cmd("Copilot enable")
        vim.g.copilot_enabled = 1
        print("Copilot enabled")
      end
    end, { desc = "Toggle Copilot autosuggestions", silent = true })
  end,
}

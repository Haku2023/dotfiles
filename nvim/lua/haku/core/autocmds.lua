-- telescope preview show linenumber
vim.cmd("autocmd User TelescopePreviewerLoaded setlocal number")

-- Create a new group for our project-specific settings to keep things tidy.
-- The { clear = true } part is important to prevent duplicating autocommands on re-sourcing.
local projectSettingsAugroup_Fortran_Yodo = vim.api.nvim_create_augroup("ProjectSettings", { clear = true })

-- Define the autocommand
vim.api.nvim_create_autocmd("BufEnter", {
  -- The pattern checks for any file under your project's directory.
  -- IMPORTANT: Change the path to your actual project path.
  -- The '*' at the end means it will match any file inside that folder and its subfolders.
  pattern = "/mnt/c/Users/baihaodong/Documents/2025Tasks/Thesis_ADE/*",
  group = projectSettingsAugroup_Fortran_Yodo,
  desc = "Set tab width to 4 for my Fortran project",
  callback = function()
    -- vim.bo are buffer-local options. This is crucial!
    -- It means these settings will ONLY apply to the buffers (files) in this project
    -- and won't change your global settings.
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
    print("Project settings applied: Tabs set to 4 spaces.") -- Optional: for confirmation
  end,
})

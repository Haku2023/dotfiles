-- telescope preview show linenumber
vim.cmd("autocmd User TelescopePreviewerLoaded setlocal number")

-- Auto-align OpenMP directives in Fortran files
local fortranOmpAugroup = vim.api.nvim_create_augroup("FortranOmpAlign", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.f90", "*.f", "*.F90", "*.F", "*.for" },
  group = fortranOmpAugroup,
  desc = "Align !$omp directives to first column before save",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local view = vim.fn.winsaveview()

    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    local changed = false
    for i, line in ipairs(lines) do
      local new = line:gsub("^%s*%!%$omp", "!$omp")
      if new ~= line then
        lines[i] = new
        changed = true
      end
    end

    if changed then
      -- one buffer update; typically gives a single clean undo step
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end

    vim.fn.winrestview(view)
    vim.api.nvim_set_current_win(win)
  end,
})

-- it use %s changed the jumplist, above use lua to change buffer without affecting jumplist
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = { "*.f90", "*.f", "*.F90", "*.F", "*.for" },
--   group = fortranOmpAugroup,
--   desc = "Align !$omp directives to first column before save",
--   callback = function()
--     -- Save cursor position
--     local cursor_pos = vim.api.nvim_win_get_cursor(0)
--     local view = vim.fn.winsaveview()
--
--     -- Use keepjumps and keeppatterns to avoid polluting jumplist
--     vim.cmd([[silent! keepjumps keeppatterns %s/^\s*!\$omp/!\$omp/e]])
--
--     -- Restore view and cursor
--     vim.fn.winrestview(view)
--     vim.api.nvim_win_set_cursor(0, cursor_pos)
--   end,
-- })

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
    -- print("Project settings applied: Tabs set to 4 spaces.") -- Optional: for confirmation
  end,
})

-- auto detect latex
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.tex",
  callback = function()
    vim.cmd("filetype detect")
  end,
})

-- Fix C/C++: prevent ':' from triggering auto-indent (fixes std:: de-indenting)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.indentkeys:remove(":")
  end,
})

-- Close CodeCompanion chat jobs before quitting to avoid E948/E676 errors
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].filetype == "codecompanion" then
        pcall(vim.api.nvim_buf_delete, buf, { force = true })
      end
    end
  end,
})

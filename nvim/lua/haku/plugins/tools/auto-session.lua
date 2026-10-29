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

    local saved_panels = {}

    local function tabpage_call(tab, callback)
      local original_tab = vim.api.nvim_get_current_tabpage()
      local original_win = vim.api.nvim_get_current_win()

      vim.api.nvim_set_current_tabpage(tab)
      local ok, err = xpcall(callback, debug.traceback)

      if vim.api.nvim_tabpage_is_valid(original_tab) then
        vim.api.nvim_set_current_tabpage(original_tab)
      end
      if vim.api.nvim_win_is_valid(original_win) then
        vim.api.nvim_set_current_win(original_win)
      end

      if not ok then
        error(err)
      end
    end
    local function prepare_session()
      saved_panels = {}

      for index, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local panels = { tree = false, chat = false }
        saved_panels[index] = panels

        local windows = vim.api.nvim_tabpage_list_wins(tab)
        local has_editor = false

        for _, win in ipairs(windows) do
          local buf = vim.api.nvim_win_get_buf(win)
          local ft = vim.bo[buf].filetype

          panels.tree = panels.tree or ft == "NvimTree"
          panels.chat = panels.chat or ft == "codecompanion"

          if
            vim.bo[buf].buftype == ""
            and ft ~= "codecompanion"
            and ft ~= "NvimTree"
            and vim.api.nvim_win_get_config(win).relative == ""
          then
            has_editor = true
          end
        end

        -- Keep an editor window even in a tab containing only panels.
        if not has_editor then
          tabpage_call(tab, function()
            vim.cmd("botright new")
          end)
        end

        for _, win in ipairs(windows) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.bo[buf].filetype
            local floating = vim.api.nvim_win_get_config(win).relative ~= ""

            if floating or vim.bo[buf].buftype ~= "" or ft == "NvimTree" or ft == "codecompanion" then
              -- Avoid discarding modified panel contents.
              vim.api.nvim_win_close(win, false)
            end
          end
        end
      end
    end

    local function reopen_panels(panels)
      local original_win = vim.api.nvim_get_current_win()

      for index, tab in ipairs(vim.api.nvim_list_tabpages()) do
        local state = panels[index]
        if state then
          tabpage_call(tab, function()
            if state.tree then
              require("nvim-tree.api").tree.open()
            end

            if state.chat then
              local Chat = require("codecompanion.interactions.chat")
              if not Chat.is_visible() then
                vim.cmd("CodeCompanionChat Toggle")
              end
            end
          end)
        end
      end

      if vim.api.nvim_win_is_valid(original_win) then
        vim.api.nvim_set_current_win(original_win)
      end
    end
    auto_session.setup({
      auto_save = false,
      auto_restore = true,
      args_allow_single_directory = true,
      suppressed_dirs = { "~/", "~/Downloads", "~/Documents", "~/Desktop/", "~/dotfiles/", "~/haku_posts/" },
      bypass_save_filetypes = { "alpha" },
      no_restore_cmds = { show_alpha_if_empty },
      -- post_restore_cmds = { show_alpha_if_empty },
      -- Our pre-save hook handles panel cleanup for manual saves too.
      close_unsupported_windows = false,

      pre_save_cmds = { prepare_session },

      save_extra_data = function()
        return vim.json.encode({ tabs = saved_panels })
      end,

      restore_extra_data = function(_, data)
        local decoded = vim.json.decode(data)
        vim.schedule(function()
          reopen_panels(decoded.tabs or {})
        end)
      end,

      -- Reopen the allowed panels after saving.
      post_save_cmds = {
        function()
          reopen_panels(saved_panels)
        end,
      },

      post_restore_cmds = { show_alpha_if_empty },
    })

    local keymap = vim.keymap

    keymap.set("n", "<leader>wr", "<cmd>AutoSession restore<CR>", { desc = "Restore session for cwd" })
    keymap.set("n", "<leader>ws", "<cmd>AutoSession save<CR>", { desc = "Save session for auto session root dir" })
    keymap.set("n", "<leader>wd", "<cmd>AutoSession delete<CR>", { desc = "Save session for auto session root dir" })
  end,
}

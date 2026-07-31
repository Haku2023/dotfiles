return {
  {
    "bfredl/nvim-miniyank",
    -- loads on startup; you can also make it lazy-load if you want
    config = function()
      -- Optional: make it persist across reboots (README suggestion)
      -- vim.g.miniyank_filename = vim.fn.expand("~/.miniyank.mpack")

      -- Optional: more history items
      -- vim.g.miniyank_maxitems = 100

      -- Recommended mappings from the README:
      -- "autoput" replaces normal p/P but keeps register behavior
      vim.keymap.set({ "n", "x" }, "p", "<Plug>(miniyank-autoput)")
      vim.keymap.set({ "n", "x" }, "P", "<Plug>(miniyank-autoPut)")

      -- Alternative: "startput" (explicit yank-history put)
      -- vim.keymap.set({ "n", "x" }, "<leader>p", "<Plug>(miniyank-startput)")
      -- vim.keymap.set({ "n", "x" }, "<leader>P", "<Plug>(miniyank-startPut)")

      -- Cycle through yank history after putting
      vim.keymap.set({ "n", "x" }, "<leader>pn", "<Plug>(miniyank-cycle)")
      vim.keymap.set({ "n", "x" }, "<leader>pN", "<Plug>(miniyank-cycleback)")

      -- Fix register type after put (char/line/block)
      vim.keymap.set({ "n", "x" }, "<leader>pc", "<Plug>(miniyank-tochar)")
      vim.keymap.set({ "n", "x" }, "<leader>pl", "<Plug>(miniyank-toline)")
      vim.keymap.set({ "n", "x" }, "<leader>pb", "<Plug>(miniyank-toblock)")

      -- Numbered "slots" backed by named registers (slot 1 = "a, slot 2 = "b, ...).
      -- miniyank only keeps a linear ring; these give you stable, addressable slots.
      -- NOTE: named registers are used on purpose — numbered registers "1-"9 get
      -- reshuffled by Vim on every delete, so they can't be used as stable slots.
      local slots = { "a", "b", "c", "d", "e", "f", "g", "h", "i" }
      for i, reg in ipairs(slots) do
        -- yank selection into slot i (visual mode)
        vim.keymap.set("x", "<leader>y" .. i, '"' .. reg .. "y", { desc = "Yank to slot " .. i })
        -- paste from slot i (normal + visual)
        vim.keymap.set({ "n", "x" }, "<leader>p" .. i, '"' .. reg .. "p", { desc = "Paste slot " .. i })
      end

      -- Telescope picker listing ONLY the yank slots above, labeled 1..N (not the
      -- register letters, and not every other register). Empty slots are skipped.
      vim.keymap.set("n", "<leader>yl", function()
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local previewers = require("telescope.previewers")

        local entries = {}
        for i, reg in ipairs(slots) do
          local content = vim.fn.getreg(reg)
          if content ~= "" then
            table.insert(entries, { idx = i, reg = reg, content = content })
          end
        end

        pickers
          .new({}, {
            prompt_title = "Yank Slots",
            finder = finders.new_table({
              results = entries,
              entry_maker = function(e)
                -- results list stays one line per slot; full content goes to preview
                local first = vim.split(e.content, "\n", { plain = true })[1]
                local display = string.format("%d: %s", e.idx, first)
                return { value = e, display = display, ordinal = display }
              end,
            }),
            sorter = conf.generic_sorter({}),
            previewer = previewers.new_buffer_previewer({
              title = "Slot Contents",
              define_preview = function(self, entry)
                local lines = vim.split(entry.value.content, "\n", { plain = true })
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
              end,
            }),
            attach_mappings = function(bufnr)
              actions.select_default:replace(function()
                actions.close(bufnr)
                local sel = action_state.get_selected_entry()
                if sel then
                  vim.cmd('normal! "' .. sel.value.reg .. "p")
                end
              end)
              return true
            end,
          })
          :find()
      end, { desc = "List yank slots" })
    end,
  },
}

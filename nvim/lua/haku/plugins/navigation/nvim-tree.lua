return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local nvimtree = require("nvim-tree")

    --recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    -- Transparent background for nvim-tree
    vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "NONE" })

    nvimtree.setup({
      view = {
        width = 35,
        relativenumber = true,
        number = true,
      },
      -- change folder arrow icons
      renderer = {
        indent_markers = {
          enable = true,
        },
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "", -- arrow when folder is closed
              arrow_open = "", -- arrow when folder is open
            },
          },
        },
      },
      -- disable window_picker for
      -- explorer to work well with
      -- window splits
      actions = {
        -- expand_all = {},
        open_file = {
          window_picker = {
            enable = false,
          },
        },
      },
      filters = {
        custom = { ".DS_Store" },
      },
      git = {
        ignore = false,
      },

      live_filter = {
        always_show_folders = false,
      },

      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.map.on_attach.default(bufnr)

        vim.keymap.set("n", "f", function()
          api.filter.live.clear()
          api.tree.expand_all()
          api.filter.live.start()

          vim.schedule(function()
            if vim.bo.filetype == "NvimTreeFilter" then
              -- \c makes the filter case-insensitive
              vim.api.nvim_buf_set_lines(0, 0, -1, false, { "\\c" })
              vim.api.nvim_win_set_cursor(0, { 1, 2 })
            end
          end)
        end, {
          buffer = bufnr,
          desc = "Filter recursively, ignoring case",
          noremap = true,
          silent = true,
          nowait = true,
        })
      end,
    })

    -- set keymaps
    local keymap = vim.keymap -- for conciseness
    local api = require("nvim-tree.api")
    keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
    keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" })
    keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" })
    keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" })
  end,
}

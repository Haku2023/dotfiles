return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    {
      "nvim-telescope/telescope-fzf-native.nvim",

      build = function()
        if vim.loop.os_uname().sysname == "Windows_NT" then
          return "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build"
        else
          return "make"
        end
      end,
    },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod

    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")

    -- or create your custom action
    local custom_actions = transform_mod({
      open_trouble_qflist = function(prompt_bufnr)
        trouble.toggle("quickfix")
      end,
    })

    local previewers = require("telescope.previewers")
    local orig_maker = previewers.buffer_previewer_maker

    telescope.setup({
      defaults = {
        preview = {
          filesize_limit = 2.0,
          timeout = 150,
        },

        buffer_previewer_maker = function(filepath, bufnr, opts)
          orig_maker(filepath, bufnr, opts)
          if filepath:match("%.[Ff]90$") then
            vim.schedule(function()
              vim.bo[bufnr].filetype = "fortran" -- keep ft consistent
              -- vim.b[bufnr].fortran_fixed_source = 1
              -- vim.b[bufnr].fortran_free_source = 0
              -- vim.bo[bufnr].syntax = "fortran" -- attach regex syntax
            end)
          end
        end,
        path_display = { "smart" },
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
          },
        },
      },
    })

    telescope.load_extension("fzf")

    -- set keymaps
    local keymap = vim.keymap -- for conciseness
    local builtin = require("telescope.builtin")

    keymap.set("n", "<leader>fm", builtin.marks, { desc = "Fuzzy find marks" })
    keymap.set("n", "<leader>bb", function()
      builtin.buffers({ sort_mru = true })
    end, { desc = "Fuzzy find in buffers" })
    keymap.set("n", "<leader>fb", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in current buffer" })
    keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find string in cwd" })
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
    keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
    keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<cr>", { desc = "Find keymaps?" })
  end,
}

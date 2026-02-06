return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED
    harpoon:setup()
    -- REQUIRED

    vim.keymap.set("n", "<leader>hh", function()
      harpoon:list():add()
    end, { desc = "add harpoon" })
    vim.keymap.set("n", "<leader>ho", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "harpoon list" })

    -- vim.keymap.set("n", "<C-h>", function()
    --   harpoon:list():select(1)
    -- end)
    -- vim.keymap.set("n", "<C-t>", function()
    --   harpoon:list():select(2)
    -- end)
    -- vim.keymap.set("n", "<C-n>", function()
    --   harpoon:list():select(3)
    -- end)
    -- avoid with save shortcut
    -- vim.keymap.set("n", "<C-s>", function()
    --   harpoon:list():select(4)
    -- end)

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set("n", "<leader>hp", function()
      harpoon:list():prev({ ui_nav_wrap = true })
      -- require("harpoon.ui").nav_prev()
    end, { desc = "Harpoon prev" })
    vim.keymap.set("n", "<leader>hn", function()
      harpoon:list():next({ ui_nav_wrap = true })
    end, { desc = "Harpoon next" })
    -- basic telescope configuration
    -- local conf = require("telescope.config").values
    -- local function toggle_telescope(harpoon_files)
    --   local file_paths = {}
    --   for _, item in ipairs(harpoon_files.items) do
    --     table.insert(file_paths, item.value)
    --   end
    --
    --   require("telescope.pickers")
    --     .new({}, {
    --       prompt_title = "Harpoon",
    --       finder = require("telescope.finders").new_table({
    --         results = file_paths,
    --       }),
    --       previewer = conf.file_previewer({}),
    --       sorter = conf.generic_sorter({}),
    --     })
    --     :find()
    -- end

    -- add remove feature telescope configuration
    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
      -- local file_paths = {}
      -- for _, item in ipairs(harpoon_files.items) do
      --   table.insert(file_paths, item.value)
      -- end
      local finder = function()
        local paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(paths, item.value)
        end

        return require("telescope.finders").new_table({
          results = paths,
        })
      end

      require("telescope.pickers")
        .new({}, {

          prompt_title = "Harpoon",
          finder = finder(),
          -- previewer = false,
          previewer = conf.file_previewer({}),
          sorter = require("telescope.config").values.generic_sorter({}),
          layout_config = {
            -- height = 0.4,
            -- width = 0.5,
            -- prompt_position = "top",
            -- preview_cutoff = 120,
          },
          attach_mappings = function(prompt_bufnr, map)
            map("i", "<C-d>", function()
              local state = require("telescope.actions.state")
              local selected_entry = state.get_selected_entry()
              local current_picker = state.get_current_picker(prompt_bufnr)

              table.remove(harpoon_files.items, selected_entry.index)
              current_picker:refresh(finder())
            end)
            return true
          end,
        })
        :find()
    end

    vim.keymap.set("n", "<C-e>", function()
      toggle_telescope(harpoon:list())
    end, { desc = "Open harpoon window" })
  end,
}

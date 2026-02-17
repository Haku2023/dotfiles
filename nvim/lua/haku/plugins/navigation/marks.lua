return {
  "chentoast/marks.nvim",
  event = "VeryLazy",
  opts = {},

  config = function()
    require("marks").setup({
      -- whether to map keybinds or not. default true
      default_mappings = true,
      -- which builtin marks to show. default {}
      -- builtin_marks = { ".", "<", ">", "^" },
      signs = true,
      -- whether movements cycle back to the beginning/end of buffer. default true
      cyclic = true,
      -- whether the shada file is updated after modifying uppercase marks. default false
      force_write_shada = false,
      -- how often (in ms) to redraw signs/recompute mark positions.
      -- higher values will have better performance but may cause visual lag,
      -- while lower values may cause performance penalties. default 150.
      refresh_interval = 250,
      -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
      -- marks, and bookmarks.
      -- can be either a table with all/none of the keys, or a single number, in which case
      -- the priority applies to all marks.
      -- default 10.
      sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
      -- disables mark tracking for specific filetypes. default {}
      excluded_filetypes = {},
      -- disables mark tracking for specific buftypes. default {}
      excluded_buftypes = {},
      -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
      -- sign/virttext. Bookmarks can be used to group together positions and quickly move
      -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
      -- default virt_text is "".
      bookmark_0 = {
        sign = "⚑",
        virt_text = "Haku BookMark 0",
        -- explicitly prompt for a virtual line annotation when setting a bookmark from this group.
        -- defaults to false.
        annotate = false,
      },
      mappings = {
        toggle = "<leader>m",
        -- next = "<leader>l",
        -- prev = "<leader>L",
        delete_buf = "<leader>kl",
      },
    })
    -- vim.api.nvim_set_hl(0, "MarkSignHL", {})
    -- vim.api.nvim_set_hl(0, "MarkSignNumHL", { bg = "NONE", fg = "#000000", force = true })
    local icon = "" --"󰓎"
    local marks_utils = require("marks.utils")
    -- Tweak from https://github.com/chentoast/marks.nvim/blob/a69253e4b471a2421f9411bc5bba127eef878dc0/lua/marks/utils.lua#L9
    marks_utils.add_sign = function(bufnr, text, line, id, group, priority)
      priority = priority or 10
      local sign_name = "Marks_" .. text
      if not marks_utils.sign_cache[sign_name] then
        marks_utils.sign_cache[sign_name] = true
        vim.api.nvim_set_hl(0, "MarkSignHL", { bg = "NONE", bold = true, fg = "LightGreen", force = true })
        vim.fn.sign_define(sign_name, { text = icon, texthl = "MarkSignHL", numhl = "MarkSignHL" })
      end
      vim.fn.sign_place(id, group, sign_name, bufnr, { lnum = line, priority = priority })
    end

    vim.keymap.set("n", "<leader>l", "m'<cmd>lua require('marks').next()<CR>", { desc = "Next mark" })
    vim.keymap.set("n", "<leader>L", "m'<cmd>lua require('marks').prev()<CR>", { desc = "Prev mark" })
  end,
}

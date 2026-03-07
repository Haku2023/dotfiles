return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  branch = "main",
  init = function()
    -- Disable entire built-in ftplugin mappings to avoid conflicts.
    -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
    -- vim.g.no_plugin_maps = true

    -- Or, disable per filetype (add as you like)
    -- vim.g.no_python_maps = true
    -- vim.g.no_ruby_maps = true
    -- vim.g.no_rust_maps = true
    -- vim.g.no_go_maps = true
  end,
  config = function()
    -- configuration
    require("nvim-treesitter-textobjects").setup({
      select = {
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        -- You can choose the select mode (default is charwise 'v')
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * method: eg 'v' or 'o'
        -- and should return the mode ('v', 'V', or '<c-v>') or a table
        -- mapping query_strings to modes.
        selection_modes = {
          ["@parameter.outer"] = "v", -- charwise
          ["@function.outer"] = "V", -- linewise
          -- ['@class.outer'] = '<c-v>', -- blockwise
        },
        -- If you set this to `true` (default is `false`) then any textobject is
        -- extended to include preceding or succeeding whitespace. Succeeding
        -- whitespace has priority in order to act similarly to eg the built-in
        -- `ap`.
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * selection_mode: eg 'v'
        -- and should return true of false
        include_surrounding_whitespace = false,
      },
    })

    -- keymaps
    -- You can use the capture groups defined in `textobjects.scm`
    vim.keymap.set({ "x", "o" }, "am", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "im", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ac", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ic", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
    end)
    -- You can also use captures from other query groups like `locals.scm`
    vim.keymap.set({ "x", "o" }, "as", function()
      require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
    end)
    -- configuration
    require("nvim-treesitter-textobjects").setup({
      move = {
        -- whether to set jumps in the jumplist
        set_jumps = true,
      },
    })

    -- keymaps
    -- You can use the capture groups defined in `textobjects.scm`
    vim.keymap.set({ "n", "x", "o" }, "]m", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "]]", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
    end)
    -- You can also pass a list to group multiple queries.
    vim.keymap.set({ "n", "x", "o" }, "]o", function()
      require("nvim-treesitter-textobjects.move").goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
    end)
    -- You can also use captures from other query groups like `locals.scm` or `folds.scm`
    vim.keymap.set({ "n", "x", "o" }, "]s", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@local.scope", "locals")
    end)
    vim.keymap.set({ "n", "x", "o" }, "]z", function()
      require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
    end)

    vim.keymap.set({ "n", "x", "o" }, "]M", function()
      require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "][", function()
      require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
    end)

    vim.keymap.set({ "n", "x", "o" }, "[m", function()
      require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "[[", function()
      require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
    end)

    vim.keymap.set({ "n", "x", "o" }, "[M", function()
      require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "[]", function()
      require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
    end)

    -- Go to either the start or the end, whichever is closer.
    -- Use if you want more granular movements
    vim.keymap.set({ "n", "x", "o" }, "]d", function()
      require("nvim-treesitter-textobjects.move").goto_next("@conditional.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "[d", function()
      require("nvim-treesitter-textobjects.move").goto_previous("@conditional.outer", "textobjects")
    end)
    local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

    -- Repeat movement with ; and ,
    -- ensure ; goes forward and , goes backward regardless of the last direction
    vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
    vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

    -- vim way: ; goes to the direction you were moving.
    -- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
    -- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

    -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
    vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
  end,

  -- config = function()
  --   require("nvim-treesitter").setup({
  --     textobjects = {
  --       select = {
  --         enable = true,
  --
  --         -- Automatically jump forward to textobj, similar to targets.vim
  --         lookahead = true,
  --
  --         keymaps = {
  --           -- You can use the capture groups defined in textobjects.scm
  --           ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
  --           ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
  --           -- ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
  --           ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },
  --
  --           -- works for javascript/typescript files (custom capture I created in after/queries/ecma/textobjects.scm)
  --           ["a:"] = { query = "@property.outer", desc = "Select outer part of an object property" },
  --           ["i:"] = { query = "@property.inner", desc = "Select inner part of an object property" },
  --           ["l:"] = { query = "@property.lhs", desc = "Select left part of an object property" },
  --           ["r:"] = { query = "@property.rhs", desc = "Select right part of an object property" },
  --
  --           ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
  --           ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },
  --
  --           ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
  --           ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },
  --
  --           ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
  --           ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },
  --
  --           ["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
  --           ["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },
  --
  --           ["am"] = { query = "@function.outer", desc = "Select outer part of a method/function definition" },
  --           ["im"] = { query = "@function.inner", desc = "Select inner part of a method/function definition" },
  --
  --           ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
  --           ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
  --         },
  --       },
  --       swap = {
  --         enable = true,
  --         swap_next = {
  --           -- ["<leader>na"] = "@parameter.inner", -- swap parameters/argument with next
  --           ["<leader>n:"] = "@property.outer", -- swap object property with next
  --           -- ["<leader>nm"] = "@function.outer", -- swap function with next
  --         },
  --         swap_previous = {
  --           -- ["<leader>pa"] = "@parameter.inner", -- swap parameters/argument with prev
  --           ["<leader>p:"] = "@property.outer", -- swap object property with prev
  --           -- ["<leader>pm"] = "@function.outer", -- swap function with previous
  --         },
  --       },
  --       move = {
  --         enable = true,
  --         set_jumps = true, -- whether to set jumps in the jumplist
  --         goto_next_start = {
  --           ["]f"] = { query = "@call.outer", desc = "Next function call start" },
  --           ["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
  --           ["]t"] = { query = "@table.outer", desc = "Next table start" },
  --           ["]c"] = { query = "@class.outer", desc = "Next class start" },
  --           ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
  --           ["]l"] = { query = "@loop.outer", desc = "Next loop start" },
  --
  --           -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
  --           -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
  --           ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
  --           -- ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
  --         },
  --         goto_next_end = {
  --           ["]T"] = { query = "@table.outer", desc = "Next table start" },
  --           ["]F"] = { query = "@call.outer", desc = "Next function call end" },
  --           ["]M"] = { query = "@function.outer", desc = "Next method/function def end" },
  --           ["]C"] = { query = "@class.outer", desc = "Next class end" },
  --           ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
  --           ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
  --           -- ["go"] = { query = "@scope.outer", desc = "End of scope" },
  --         },
  --         goto_previous_start = {
  --           ["[f"] = { query = "@call.outer", desc = "Prev function call start" },
  --           ["[m"] = { query = "@function.outer", desc = "Prev method/function def start" },
  --           ["[t"] = { query = "@table.outer", desc = "Prev table start" },
  --           ["[c"] = { query = "@class.outer", desc = "Prev class start" },
  --           ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
  --           ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
  --           -- ["[z"] = { query = "@fold", query_group = "folds", desc = "Previous fold" },
  --         },
  --         goto_previous_end = {
  --           ["[F"] = { query = "@call.outer", desc = "Prev function call end" },
  --           ["[T"] = { query = "@table.outer", desc = "Prev table start" },
  --           ["[M"] = { query = "@function.outer", desc = "Prev method/function def end" },
  --           ["[C"] = { query = "@class.outer", desc = "Prev class end" },
  --           ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
  --           ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
  --         },
  --       },
  --     },
  --   })
  --   local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
  --
  --   -- Repeat movement with ; and ,
  --   -- ensure ; goes forward and , goes backward regardless of the last direction
  --   vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
  --   vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
  --
  --   -- vim way: ; goes to the direction you were moving.
  --   -- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
  --   -- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
  --
  --   -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
  --   vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
  --   vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
  --   vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
  --   vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
  -- end,
}

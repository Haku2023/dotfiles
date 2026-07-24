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

    -- use line marks in different buffers
    -- <<<{{{
    --
    -- Telescope picker for mark lists
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local t_actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local previewers = require("telescope.previewers")
    -- ts_repeat_move is already required in your file as `ts_repeat_move`
    local path = vim.fn.stdpath("data") .. "/haku_linemarks.json"
    -- load once per session (guard so :source doesn't re-read the file over live state)

    -- forward-declared so the Telescope picker closures below capture it as an
    -- upvalue. `activate` is defined further down; without this declaration the
    -- references inside pick_lists resolve to a nil GLOBAL, and <CR>/<C-d> in the
    -- picker error out ("attempt to call a nil value (global 'activate')").
    local activate

    -- builds the finder fresh each time (so refresh after delete reflects reality)
    local function list_finder()
      local names = vim.tbl_keys(_G.HakuMarks.lists)
      table.sort(names)
      return finders.new_table({
        results = names,
        entry_maker = function(name)
          local marks = _G.HakuMarks.lists[name]
          local active = (name == _G.HakuMarks.active) and " ●" or ""
          return {
            value = name,
            display = string.format("%-16s %d marks%s", name, #marks, active),
            ordinal = name, -- what the fuzzy search matches on
          }
        end,
      })
    end

    local function pick_lists()
      pickers
        .new({}, {
          prompt_title = "Mark Lists",
          finder = list_finder(),
          sorter = conf.generic_sorter({}),
          previewer = previewers.new_buffer_previewer({
            title = "Marks in list",
            define_preview = function(self, entry)
              local marks, lines = _G.HakuMarks.lists[entry.value] or {}, {}
              for _, m in ipairs(marks) do
                table.insert(lines, string.format("line %d, col %d", m[1], m[2]))
              end
              if #lines == 0 then
                lines = { "(empty)" }
              end
              vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
            end,
          }),
          attach_mappings = function(prompt_bufnr, map)
            -- <CR> = activate the highlighted list
            t_actions.select_default:replace(function()
              local entry = action_state.get_selected_entry()
              t_actions.close(prompt_bufnr)
              if entry then
                activate(entry.value)
              end
            end)

            -- <C-d> = delete the highlighted list, then refresh the picker in place
            local function delete_list()
              local entry = action_state.get_selected_entry()
              if not entry then
                return
              end
              _G.HakuMarks.lists[entry.value] = nil
              -- if we just deleted the active list, fall back to another (or recreate default)
              if _G.HakuMarks.active == entry.value then
                local remaining = vim.tbl_keys(_G.HakuMarks.lists)
                activate(remaining[1] or "default")
              end
              action_state.get_current_picker(prompt_bufnr):refresh(list_finder(), { reset_prompt = false })
            end
            map("i", "<C-d>", delete_list)
            map("n", "<C-d>", delete_list)

            return true
          end,
        })
        :find()
    end

    vim.keymap.set("n", "<leader>gl", pick_lists, { desc = "Mark lists (Telescope)" })

    if _G.HakuMarks == nil then
      local ok, data = pcall(function()
        return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
      end)
      if ok and type(data) == "table" and data.lists then
        _G.HakuMarks = data
      else
        _G.HakuMarks = { lists = { default = {} }, active = "default" }
      end
    end
    -- Normalize the (possibly on-disk) state so `store` is ALWAYS a table.
    -- vim.json can round-trip an empty `lists` back as `[]`, so guard the type.
    -- Every fresh nvim session starts on the "default" list (named lists are still
    -- kept on disk; you just always open into `default` after e.g. `vi abc`).
    do
      local M = _G.HakuMarks
      if type(M.lists) ~= "table" then
        M.lists = {}
      end
      M.active = "default" -- always start a new session on the default list
      M.lists[M.active] = M.lists[M.active] or {} -- guarantee the active list exists
    end
    -- local store = {} -- FLAT list of line numbers, shared by every buffer this session
    local store = _G.HakuMarks.lists[_G.HakuMarks.active]
    local ns = vim.api.nvim_create_namespace("haku_linemarks")

    -- color of the marked line NUMBER (change fg to taste)
    local function set_hl()
      vim.api.nvim_set_hl(0, "HakuLineMark", { fg = "LightBlue", bold = true })
    end
    set_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl }) -- colorschemes wipe custom hls

    -- write marks to disk before quitting
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        vim.fn.writefile({ vim.json.encode(_G.HakuMarks) }, path)
      end,
    })
    -- paint ONE buffer: clear our old marks, then tint each stored line number
    local function paint(buf)
      if not vim.api.nvim_buf_is_loaded(buf) then
        return
      end
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
      local last = vim.api.nvim_buf_line_count(buf)
      for _, mark in ipairs(store or {}) do
        local line = type(mark) == "table" and mark[1] -- skip legacy/corrupt entries
        if line and line >= 1 and line <= last then -- skip lines past this buffer's end
          vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, { -- extmark row is 0-indexed
            number_hl_group = "HakuLineMark",
          })
        end
      end
    end
    -- repaint every buffer currently visible in a window (all panes)
    local function redraw()
      local seen = {}
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if not seen[buf] then
          seen[buf] = true
          paint(buf)
        end
      end
    end
    -- newly opened/switched buffer in any pane gets painted too
    vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
      callback = function(args)
        paint(args.buf)
      end,
    })

    -- record / un-record the current line (toggle)
    local function toggle()
      -- local line = vim.api.nvim_win_get_cursor(0)[1] -- {row, col}; row is 1-indexed
      local cursor = vim.api.nvim_win_get_cursor(0)
      local row, col = cursor[1], cursor[2]
      for i, v in ipairs(store) do
        -- if v == line then
        if v[1] == row then
          table.remove(store, i)
          -- vim.notify("mark removed: " .. line)
          redraw()
          return
        end
      end
      -- table.insert(store, line)
      table.insert(store, { row, col })
      table.sort(store, function(a, b)
        return a[1] < b[1]
      end)
      -- vim.notify("mark added: " .. line)
      redraw()
    end
    -- define this at the SAME scope as `local store` (so they share the upvalue)
    -- assigns the forward-declared local above (do NOT re-`local` it, or the
    -- picker closures would keep pointing at a separate nil upvalue)
    function activate(name)
      local M = _G.HakuMarks
      M.lists[name] = M.lists[name] or {} -- create on first use
      M.active = name
      store = M.lists[name] -- <-- all closures now use this list
      redraw()
      vim.notify("mark list: " .. name)
    end

    local function clear()
      for i = #store, 1, -1 do
        store[i] = nil -- mutate in place; global stays linked
      end
      vim.notify("marks cleared")
      redraw()
    end

    -- THE single move function. Direction comes from opts.forward.
    -- This is the contract make_repeatable_move / ; / , expect.
    local function goto_mark(opts)
      -- local m = marks()
      if #store == 0 then
        return
      end
      -- local cur = vim.api.nvim_win_get_cursor(0)[1]
      local cursor = vim.api.nvim_win_get_cursor(0)
      local row = cursor[1]
      local target -- the full { row, col } mark
      if opts and opts.forward == false then -- going backward
        for i = #store, 1, -1 do
          if store[i][1] < row then
            target = store[i]
            break
          end
        end
        target = target or store[#store] -- wrap to last
      else -- going forward
        for _, v in ipairs(store) do
          if v[1] > row then
            target = v
            break
          end
        end
        target = target or store[1] -- wrap to first
      end
      vim.api.nvim_win_set_cursor(0, { target[1], target[2] }) -- col is 0-indexed
    end

    -- wrap it so ; and , can repeat it
    local mark_move = ts_repeat_move.make_repeatable_move(goto_mark)

    vim.keymap.set("n", "<leader>ga", function()
      vim.ui.input({ prompt = "Activate mark list: " }, function(name)
        if name and name ~= "" then
          activate(name)
        end
      end)
    end, { desc = "Activate mark list" })
    -- <leader>gg : jump to first mark AND arm ; / , for mark navigation
    vim.keymap.set("n", "<leader>gn", function()
      if #store == 0 then
        return
      end
      local cursor = vim.api.nvim_win_get_cursor(0)
      local row = cursor[1]
      local target -- the full { row, col } mark
      for _, v in ipairs(store) do
        if v[1] > row then
          target = v
          break
        end
      end
      target = target or store[1] -- wrap to first
      vim.api.nvim_win_set_cursor(0, { target[1], target[2] })
      -- this is the exact table shape ; and , read (see builtin_f_expr in the plugin)
      ts_repeat_move.last_move = { func = goto_mark, opts = { forward = true }, additional_args = {} }
    end, { desc = "Goto next marked line" })

    vim.keymap.set("n", "<leader>gg", toggle, { desc = "Toggle line mark" })
    vim.keymap.set("n", "<leader>gc", clear, { desc = "Clear line mark" })

    -- optional, if you also want bracket motions:
    vim.keymap.set("n", "]g", function()
      mark_move({ forward = true })
    end, { desc = "Next mark" })
    vim.keymap.set("n", "[g", function()
      mark_move({ forward = false })
    end, { desc = "Prev mark" })
  end,
  -- <<<}}}

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

return {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "jay-babu/mason-nvim-dap.nvim",
    "theHamsta/nvim-dap-virtual-text",
  },
  config = function()
    local mason_dap = require("mason-nvim-dap")
    local dap = require("dap")
    local ui = require("dapui")
    local dap_virtual_text = require("nvim-dap-virtual-text")

    -- Dap Virtual Text
    dap_virtual_text.setup()

    mason_dap.setup({
      ensure_installed = { "cppdbg", "codelldb", "python", "fortran" },
      automatic_installation = true,
      handlers = {
        function(config)
          if config.name == "codelldb" or config.name == "cppdbg" then
            return
          end
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    })

    -- Detect OS for debugger selection
    local is_mac = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
    local debugger_mode = is_mac and "lldb" or "gdb"
    local debugger_path = is_mac and "/usr/bin/lldb" or "/usr/bin/gdb"

    -- Scaffold a starter .nvim/dap.lua in the cwd the first time you start a
    -- debug session (see <Leader>dq), so per-file build/program/args are easy
    -- to fill in. Never overwrites an existing file.
    local dap_config_template = [[return {
  cpp = {
    ["src/app.cpp"] = {
      build = "cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build -j",
      program = "build/app",
      args = { "--config", "debug", "--input", "data/input.txt" },
    },
  },

  c = {
    ["src/app.c"] = {
      build = "make debug",
      program = "build/app",
      args = { "arg1", "arg2" },
    },
  },

  python = {
    ["train.py"] = {
      args = { "--epochs", "3", "--debug" },
    },
  },
  fortran = {
    ["main.F90"] = {
      build = "gfortran -g -o main main.F90",
      program = "main",
      args = { "arg1", "arg2" },
    },
  },
}
]]

    local function ensure_project_dap_config()
      local project_dap = vim.fn.getcwd() .. "/.nvim/dap.lua"

      if vim.fn.filereadable(project_dap) == 1 then
        return
      end

      vim.fn.mkdir(vim.fn.fnamemodify(project_dap, ":h"), "p")
      vim.fn.writefile(vim.split(dap_config_template, "\n"), project_dap)
      vim.notify("DAP: created " .. project_dap, vim.log.levels.INFO)
    end

    local function project_config_for(lang)
      local project_dap = vim.fn.getcwd() .. "/.nvim/dap.lua"
      local file = vim.fn.expand("%:.")

      if vim.fn.filereadable(project_dap) == 1 then
        local ok, config = pcall(dofile, project_dap)

        if ok and config[lang] then
          -- Exact relative-path key wins.
          if config[lang][file] then
            return config[lang][file]
          end

          -- Fall back to glob keys (e.g. "**/*.F90"). glob2regpat yields a
          -- Vim regex, so match with Vim's engine (not Lua's :match).
          for pattern, entry in pairs(config[lang]) do
            if vim.fn.match(file, vim.fn.glob2regpat(pattern)) >= 0 then
              return entry
            end
          end
        end
      end

      return {}
    end

    local function build_then_get_program(lang)
      local cfg = project_config_for(lang)

      if cfg.build then
        if cfg.program then
          vim.fn.mkdir(vim.fn.fnamemodify(cfg.program, ":h"), "p")
        end

        local result = vim.fn.system(cfg.build)

        if vim.v.shell_error ~= 0 then
          error("Build failed:\n" .. result)
        end
      end

      if not cfg.program then
        error("No program configured for " .. vim.fn.expand("%:."))
      end

      return vim.fn.getcwd() .. "/" .. cfg.program
    end

    -- fortran
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
        args = { "--port", "${port}" },
      },
    }
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    }

    -- Configurations
    dap.configurations.fortran = {
      {
        name = "Debug Fortran with gdb",
        type = "gdb",
        request = "launch",
        program = function()
          return build_then_get_program("fortran")
        end,
        args = function()
          return project_config_for("fortran").args or {}
        end,
        -- Under the debugger stdout is a pipe (not a TTY), so the gfortran
        -- runtime full-buffers it and `print *` output isn't shown until the
        -- buffer fills or the program exits. Force the preconnected units
        -- (stdout/stderr) unbuffered so prints appear live while stepping.
        env = { GFORTRAN_UNBUFFERED_PRECONNECTED = "y" },
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
      },
    }

    dap.configurations.c = {
      {
        name = "Build and debug project C file",
        -- type = "cppdbg",
        type = "codelldb",
        request = "launch",
        cwd = "${workspaceFolder}",
        program = function()
          return build_then_get_program("c")
        end,
        args = function()
          return project_config_for("c").args or {}
        end,
      },
    }

    -- {
    --   name = "Launch file",
    --   type = "cppdbg",
    --   request = "launch",
    --   program = function()
    --     return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    --   end,
    --   cwd = "${workspaceFolder}",
    --   stopAtEntry = false,
    --   MIMode = debugger_mode,
    --   miDebuggerPath = debugger_path,
    -- },
    -- {
    --   name = "Attach to lldbserver :1234",
    --   type = "cppdbg",
    --   request = "launch",
    --   MIMode = "lldb",
    --   miDebuggerServerAddress = "localhost:1234",
    --   miDebuggerPath = "/usr/bin/lldb",
    --   cwd = "${workspaceFolder}",
    --   program = function()
    --     return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    --   end,
    -- },
    -- }
    dap.configurations.cpp = {
      {
        name = "Build and debug project C++ file",
        type = "codelldb",
        request = "launch",
        cwd = "${workspaceFolder}",
        program = function()
          return build_then_get_program("cpp")
        end,
        args = function()
          return project_config_for("cpp").args or {}
        end,
      },
    }
    -- python comment,since use mason default config
    --/Users/bai.haodong/.local/share/nvim/lazy/mason-nvim-dap.nvim/lua/mason-nvim-dap/mappings/configurations.lua
    --
    local venv_path = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
    dap.configurations.python = {
      {
        -- The first three options are required by nvim-dap
        type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
        request = "launch",
        name = "Python: Launch file",
        program = "${file}", -- This configuration will launch the current file if used.
        -- venv on Windows uses Scripts instead of bin
        pythonPath = venv_path
            and ((vim.fn.has("win32") == 1 and venv_path .. "/Scripts/python") or venv_path .. "/bin/python")
          or nil,
        console = "integratedTerminal",
        args = function()
          local cfg = project_config_for("python")
          return cfg.args or {}
          -- local project_dap = vim.fn.getcwd() .. "/.nvim/dap.lua"
          --
          -- if vim.fn.filereadable(project_dap) == 1 then
          --   local ok, config = pcall(dofile, project_dap)
          --   if ok and config.args then
          --     return config.args
          --   end
          -- end
        end,
      },
    }

    -- Dap UI

    ui.setup({
      layouts = {
        -- layout 1: scopes/stacks. Left sidebar, closed by default (see
        -- listeners below); toggle it with <Leader>dt.
        {
          elements = {
            { id = "scopes", size = 0.5 },
            { id = "stacks", size = 0.5 },
          },
          size = 0.25,
          position = "left",
        },
        -- layout 2: the right half of the screen (size 0.5 == 50% width).
        -- NOTE: dapui layouts are 1-dimensional, so the right half can't be a
        -- 2x grid. Side-by-side (watches|breakpoints) only works in a
        -- full-width top/bottom layout, which can't be confined to the right
        -- half -- so watches / breakpoints / console are stacked top->bottom.
        {
          elements = {
            { id = "watches", size = 0.35 },
            { id = "breakpoints", size = 0.30 },
            -- gdb's DAP streams program stdout/stderr as `output` events
            -- (it doesn't use runInTerminal), so they land in the `repl`,
            -- not the `console` element. Show the repl or `print` output is
            -- invisible. (console only fills for runInTerminal adapters.)
            { id = "repl", size = 0.35 },
          },
          size = 0.5,
          position = "right",
        },
      },
      controls = {
        enabled = true,
        element = "repl",
      },
      element_mappings = {
        watches = {
          edit = {},
          remove = {},
        },
        breakpoints = {
          -- <CR> is "expand" globally, which breakpoints can't do; map it to
          -- "open" so Enter jumps to the breakpoint's file/line.
          -- open = "<CR>",
        },
      },
    })

    local function watch_index_under_cursor()
      local line = vim.api.nvim_get_current_line()
      local watches = ui.elements.watches.get()
      local best_index
      local best_length = 0

      for index, watch in ipairs(watches) do
        if line:find(watch.expression, 1, true) and #watch.expression > best_length then
          best_index = index
          best_length = #watch.expression
        end
      end

      return best_index
    end

    local function select_watch(prompt, callback)
      local watches = ui.elements.watches.get()

      if #watches == 0 then
        vim.notify("No watches", vim.log.levels.INFO)
        return
      end

      vim.ui.select(watches, {
        prompt = prompt,
        format_item = function(item)
          return item.expression
        end,
      }, function(item, index)
        if item and index then
          callback(index, item)
        end
      end)
    end

    local function edit_watch()
      local index = watch_index_under_cursor()

      local function edit(index_, watch)
        vim.ui.input({
          prompt = "Watch: ",
          default = watch.expression,
        }, function(expr)
          if expr and expr ~= "" then
            ui.elements.watches.edit(index_, expr)
          end
        end)
      end

      if index then
        edit(index, ui.elements.watches.get()[index])
      else
        select_watch("Edit watch:", edit)
      end
    end

    local function remove_watch()
      local index = watch_index_under_cursor()

      if index then
        ui.elements.watches.remove(index)
      else
        select_watch("Remove watch:", function(index_)
          ui.elements.watches.remove(index_)
        end)
      end
    end

    -- The watches buffer is created once and cached by dapui, and its filetype
    -- is set in an async context, so a FileType autocmd alone is unreliable
    -- (it can be missed for some sessions). Make the keymap setup idempotent
    -- and also assert it after ui.open() in the dap listeners below.
    local function ensure_watches_keymaps(buf)
      if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      vim.keymap.set("n", "e", edit_watch, { buffer = buf, desc = "DAP: Edit watch", nowait = true })
      vim.keymap.set("n", "d", remove_watch, { buffer = buf, desc = "DAP: Remove watch", nowait = true })
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dapui_watches",
      callback = function(event)
        ensure_watches_keymaps(event.buf)
      end,
    })

    -- Syntax-highlight the source line shown for each breakpoint, using the
    -- filetype of the file it came from. dapui renders that line as plain text,
    -- so we re-apply Treesitter highlights after each render. The language is
    -- inferred per section from the header line (the file's basename).
    local bp_syntax_ns = vim.api.nvim_create_namespace("dapui_breakpoints_syntax")

    local function highlight_breakpoints_source(buf)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      vim.api.nvim_buf_clear_namespace(buf, bp_syntax_ns, 0, -1)

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local lang

      for row, line in ipairs(lines) do
        local header = line:match("^(%S.*):$")
        if header then
          -- Section header is the file's basename, e.g. "main.c:".
          local ft = vim.filetype.match({ filename = header })
          lang = ft and vim.treesitter.language.get_lang(ft) or nil
        elseif lang then
          -- Breakpoint line: "<indent><lnum> <source code>".
          local prefix, code = line:match("^(%s*%d+ )(.*)$")
          if code and code ~= "" then
            local ok, parser = pcall(vim.treesitter.get_string_parser, code, lang)
            local query = ok and vim.treesitter.query.get(lang, "highlights")
            if ok and query then
              local tree = parser:parse()[1]
              local offset = #prefix
              for id, node in query:iter_captures(tree:root(), code, 0, -1) do
                local start_row, start_col, end_row, end_col = node:range()
                if start_row == 0 and end_row == 0 then
                  pcall(vim.api.nvim_buf_set_extmark, buf, bp_syntax_ns, row - 1, offset + start_col, {
                    end_col = offset + end_col,
                    hl_group = "@" .. query.captures[id],
                    priority = 120,
                  })
                end
              end
            end
          end
        end
      end
    end

    -- Idempotent: re-highlight now, and attach an on_lines hook exactly once
    -- per buffer so re-renders (which wipe our extmarks) get re-highlighted.
    local function ensure_breakpoints_highlight(buf)
      if not buf or not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      highlight_breakpoints_source(buf)
      if vim.b[buf].dapui_bp_syntax_attached then
        return
      end
      vim.b[buf].dapui_bp_syntax_attached = true

      local scheduled = false
      -- dapui rewrites the buffer on every render, wiping our extmarks, so
      -- re-highlight whenever its lines change (extmark-only, no recursion).
      vim.api.nvim_buf_attach(buf, false, {
        on_lines = function()
          if not vim.api.nvim_buf_is_valid(buf) then
            return true
          end
          if scheduled then
            return
          end
          scheduled = true
          vim.schedule(function()
            scheduled = false
            highlight_breakpoints_source(buf)
          end)
        end,
      })
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dapui_breakpoints",
      callback = function(event)
        ensure_breakpoints_highlight(event.buf)
      end,
    })

    local breakpoints = require("dap.breakpoints")
    local breakpoint_store = vim.fn.stdpath("data") .. "/dap-breakpoints.json"
    local breakpoint_filetypes = {
      c = true,
      cpp = true,
      fortran = true,
      python = true,
    }

    local function read_breakpoint_store()
      if vim.fn.filereadable(breakpoint_store) ~= 1 then
        return {}
      end

      local ok, persisted = pcall(function()
        return vim.fn.json_decode(table.concat(vim.fn.readfile(breakpoint_store), "\n"))
      end)

      if not ok or type(persisted) ~= "table" then
        return {}
      end

      return persisted
    end

    -- A single global store holds every project's breakpoints. We scope both
    -- save and load to the cwd nvim was opened in, so the breakpoints panel
    -- (<Leader>db) only ever shows the current project's breakpoints.
    local function path_in_cwd(path)
      local cwd = vim.fn.getcwd()
      local abs = vim.fn.fnamemodify(path, ":p")
      return abs == cwd or abs:sub(1, #cwd + 1) == cwd .. "/"
    end

    local function save_breakpoints()
      -- Start from the on-disk store so OTHER projects' breakpoints survive:
      -- this session only knows about the current project's breakpoints (see
      -- the cwd filter in load_breakpoints).
      local persisted = read_breakpoint_store()

      -- Clear the current project's entries up front; they're rewritten from
      -- live state below, so breakpoints removed this session don't linger.
      for path in pairs(persisted) do
        if path_in_cwd(path) then
          persisted[path] = nil
        end
      end

      for bufnr, buf_breakpoints in pairs(breakpoints.get()) do
        local path = vim.api.nvim_buf_get_name(bufnr)
        local filetype = vim.bo[bufnr].filetype

        -- Fall back to filename-based detection: a background buffer (e.g. one
        -- restored by load_breakpoints) may still have an empty filetype, and
        -- we don't want to silently drop its breakpoints from the save.
        if filetype == "" and path ~= "" then
          filetype = vim.filetype.match({ buf = bufnr, filename = path }) or ""
        end

        if path ~= "" and breakpoint_filetypes[filetype] and path_in_cwd(path) then
          persisted[path] = {}

          for _, breakpoint in ipairs(buf_breakpoints) do
            table.insert(persisted[path], {
              line = breakpoint.line,
              condition = breakpoint.condition,
              hitCondition = breakpoint.hitCondition,
              logMessage = breakpoint.logMessage,
            })
          end
        end
      end

      vim.fn.mkdir(vim.fn.fnamemodify(breakpoint_store, ":h"), "p")
      vim.fn.writefile({ vim.fn.json_encode(persisted) }, breakpoint_store)
    end

    local function load_breakpoints()
      local persisted = read_breakpoint_store()

      if vim.tbl_isempty(persisted) then
        return
      end

      -- Loading these buffers can hit E325 ATTENTION if a file already has a
      -- swap file (open in another nvim instance, or a stale .swp). Disable
      -- swapfiles and suppress the ATTENTION prompt so restore never blocks,
      -- and pcall the whole thing so one bad file can't break the config.
      local save_shortmess = vim.o.shortmess
      local save_swapfile = vim.o.swapfile
      vim.opt.shortmess:append("A")
      vim.o.swapfile = false

      local load_ok, load_err = pcall(function()
        for path, buf_breakpoints in pairs(persisted) do
          if path_in_cwd(path) and vim.fn.filereadable(path) == 1 and type(buf_breakpoints) == "table" then
            local bufnr = vim.fn.bufadd(path)
            vim.fn.bufload(bufnr)

            -- bufload() doesn't reliably run filetype detection for these
            -- background buffers, leaving filetype empty. That both excludes
            -- them from save_breakpoints (its filetype filter) -- so a
            -- breakpoint here is dropped when you next quit from a different
            -- file -- and drops syntax/Treesitter highlighting when you later
            -- jump into the file from the breakpoints panel. Detect it now.
            if vim.bo[bufnr].filetype == "" then
              local ft = vim.filetype.match({ buf = bufnr, filename = path })
              if ft then
                vim.bo[bufnr].filetype = ft
              end
            end

            for _, breakpoint in ipairs(buf_breakpoints) do
              if breakpoint.line then
                breakpoints.set({
                  condition = breakpoint.condition,
                  hitCondition = breakpoint.hitCondition,
                  logMessage = breakpoint.logMessage,
                }, bufnr, breakpoint.line)
              end
            end
          end
        end
      end)

      vim.o.swapfile = save_swapfile
      vim.o.shortmess = save_shortmess

      if not load_ok then
        vim.notify("DAP: failed to restore breakpoints: " .. tostring(load_err), vim.log.levels.WARN)
      end
    end

    load_breakpoints()

    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = save_breakpoints,
    })

    -- Open only the right-half panel (layout 2); layout 1 (scopes/stacks)
    -- stays closed until <Leader>dt. Assert our buffer customizations here too,
    -- since the FileType autocmds can be missed for cached/async buffers.
    local function open_dapui()
      ui.open({ layout = 2 })
      ensure_watches_keymaps(ui.elements.watches.buffer())
      ensure_breakpoints_highlight(ui.elements.breakpoints.buffer())
    end

    dap.listeners.before.attach.dapui_config = open_dapui
    dap.listeners.before.launch.dapui_config = function()
      open_dapui()
      dap_virtual_text.enable()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      ui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      ui.close()
    end

    -- Keymaps
    local map = vim.keymap.set

    map("n", "<Leader>dq", function()
      ensure_project_dap_config()
      dap.continue()
    end, { desc = "DAP: Continue" })
    map("n", "<Leader>dk", dap.step_over, { desc = "DAP: Step over" })
    map("n", "<Leader>dj", dap.step_into, { desc = "DAP: Step into" })
    map("n", "<Leader>dh", dap.step_out, { desc = "DAP: Step out" })
    map("n", "<Leader>b", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
    map("n", "<Leader>B", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "DAP: Set conditional breakpoint" })
    map("n", "<Leader>dr", dap.repl.open, { desc = "DAP: Open REPL" })
    map("n", "<Leader>dl", dap.run_last, { desc = "DAP: Run last" })
    -- Toggle only the main right panel (layout 2); layout 1 (scopes/stacks) is
    -- managed separately by <Leader>dt. A bare ui.toggle() toggles each layout
    -- independently, which would open the normally-closed layout 1 and close
    -- layout 2 -- the opposite of what we want.
    -- reset = true restores layout 2 to its configured default size on each
    -- toggle. Without it, dapui remembers whatever size the windows were left
    -- at -- e.g. enlarged after a CodeCompanion panel opened/closed alongside
    -- it -- and reuses that stale size when reopening.
    map("n", "<Leader>du", function()
      ui.toggle({ layout = 2, reset = true })
      dap_virtual_text.toggle()
    end, { desc = "DAP UI: Toggle" })
    -- Layout 1 is the left panel (scopes / breakpoints / stacks); toggle it alone.
    map("n", "<Leader>dt", function()
      ui.toggle({ layout = 1, reset = false })
    end, { desc = "DAP UI: Toggle scopes/stacks panel" })

    -- dap.terminate alone doesn't always close the UI: it depends on the
    -- adapter emitting event_terminated/event_exited, which some adapters skip
    -- on an explicit terminate. Close the UI (and virtual text) ourselves.
    map("n", "<Leader>ds", function()
      dap.terminate()
      ui.close()
      dap_virtual_text.disable()
    end, { desc = "DAP: Stop" })
    map("n", "<Leader>dr", dap.restart, { desc = "DAP: Restart" })

    local function focus_dapui_watches()
      local buf = ui.elements.watches.buffer()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_buf(win) == buf then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
      ui.float_element("watches", { enter = true })
    end

    vim.keymap.set("n", "<Leader>dw", focus_dapui_watches, { desc = "DAP UI: Focus Watches" })

    -- <C-l> normally calls vim-tmux-navigator's :TmuxNavigateRight, which lands
    -- in whichever right-half window (watches/breakpoints/console, layout 2)
    -- aligns with the cursor's row. While debugging, from a normal editor
    -- window we always want watches instead; everywhere else keep the default.
    local function navigate_right()
      if dap.session() and not vim.bo.filetype:match("^dapui_") and vim.bo.filetype ~= "dap-repl" then
        focus_dapui_watches()
      else
        vim.cmd("TmuxNavigateRight")
      end
    end

    vim.keymap.set("n", "<C-l>", navigate_right, { desc = "Navigate right (DAP: focus Watches)" })

    local function focus_dapui_breakpoints()
      local buf = ui.elements.breakpoints.buffer()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_buf(win) == buf then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
      ui.float_element("breakpoints", { enter = true })
    end

    vim.keymap.set("n", "<Leader>db", focus_dapui_breakpoints, { desc = "DAP UI: Focus Breakpoints" })

    -- Breakpoint sign and colors
    -- Signs
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
    vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition" })
    vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpointRejected" })
    vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped" })

    -- Colors
    vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#ff5555" })
    vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#ff5555" })
    vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#888888" })
    vim.api.nvim_set_hl(0, "DapStopped", { fg = "#50fa7b" })
  end,
}

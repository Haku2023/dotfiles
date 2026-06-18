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
      ensure_installed = { "cppdbg", "codelldb", "python" },
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

    local function project_config_for(lang)
      local project_dap = vim.fn.getcwd() .. "/.nvim/dap.lua"
      local file = vim.fn.expand("%:.")

      if vim.fn.filereadable(project_dap) == 1 then
        local ok, config = pcall(dofile, project_dap)

        if ok and config[lang] and config[lang][file] then
          return config[lang][file]
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

    -- Configurations
    dap.configurations.fortran = {
      {
        name = "Debug Fortran with LLDB",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        -- LLDB has no Fortran expression frontend, so its native evaluator throws
        -- "TypeSystem for language fortran95 doesn't exist" for watch/hover.
        -- Use codelldb's own ("simple") evaluator, which reads variables directly.
        expressions = "simple",
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
        {
          elements = {
            { id = "console", size = 0.35 },
            { id = "scopes", size = 0.15 },
            { id = "breakpoints", size = 0.35 },
            { id = "stacks", size = 0.15 },
          },
          size = 30,
          position = "left",
        },
        {
          elements = {
            { id = "watches", size = 1.0 },
          },
          size = 35,
          position = "right",
        },
      },
      controls = {
        enabled = true,
        element = "console",
      },
      element_mappings = {
        watches = {
          edit = {},
          remove = {},
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

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dapui_watches",
      callback = function(event)
        vim.keymap.set("n", "e", edit_watch, {
          buffer = event.buf,
          desc = "DAP: Edit watch",
          nowait = true,
        })
        vim.keymap.set("n", "d", remove_watch, {
          buffer = event.buf,
          desc = "DAP: Remove watch",
          nowait = true,
        })
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

    local function save_breakpoints()
      local persisted = {}

      for bufnr, buf_breakpoints in pairs(breakpoints.get()) do
        local path = vim.api.nvim_buf_get_name(bufnr)
        local filetype = vim.bo[bufnr].filetype

        if path ~= "" and breakpoint_filetypes[filetype] then
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
      if vim.fn.filereadable(breakpoint_store) ~= 1 then
        return
      end

      local ok, persisted = pcall(function()
        return vim.fn.json_decode(table.concat(vim.fn.readfile(breakpoint_store), "\n"))
      end)

      if not ok or type(persisted) ~= "table" then
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
          if vim.fn.filereadable(path) == 1 and type(buf_breakpoints) == "table" then
            local bufnr = vim.fn.bufadd(path)
            vim.fn.bufload(bufnr)

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

    dap.listeners.before.attach.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      ui.open()
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

    map("n", "<Leader>dq", dap.continue, { desc = "DAP: Continue" })
    map("n", "<Leader>dk", dap.step_over, { desc = "DAP: Step over" })
    map("n", "<Leader>dj", dap.step_into, { desc = "DAP: Step into" })
    map("n", "<Leader>dh", dap.step_out, { desc = "DAP: Step out" })
    map("n", "<Leader>b", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
    map("n", "<Leader>B", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "DAP: Set conditional breakpoint" })
    map("n", "<Leader>dr", dap.repl.open, { desc = "DAP: Open REPL" })
    map("n", "<Leader>dl", dap.run_last, { desc = "DAP: Run last" })
    map("n", "<Leader>du", function()
      ui.toggle()
      dap_virtual_text.toggle()
    end, { desc = "DAP UI: Toggle" })

    map("n", "<Leader>ds", dap.terminate, { desc = "DAP: Stop" })
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

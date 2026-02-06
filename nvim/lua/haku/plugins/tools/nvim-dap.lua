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
      ensure_installed = { "cppdbg", "python" },
      automatic_installation = true,
      handlers = {
        function(config)
          require("mason-nvim-dap").default_setup(config)
        end,
        python = function(config)
          config.configurations = {}
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    })

    -- Detect OS for debugger selection
    local is_mac = vim.fn.has("mac") == 1 or vim.fn.has("macunix") == 1
    local debugger_mode = is_mac and "lldb" or "gdb"
    local debugger_path = is_mac and "/usr/bin/lldb" or "/usr/bin/gdb"

    -- Configurations
    dap.configurations = {
      c = {
        {
          name = "Launch file",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          MIMode = debugger_mode,
          miDebuggerPath = debugger_path,
        },
        {
          name = "Attach to lldbserver :1234",
          type = "cppdbg",
          request = "launch",
          MIMode = "lldb",
          miDebuggerServerAddress = "localhost:1234",
          miDebuggerPath = "/usr/bin/lldb",
          cwd = "${workspaceFolder}",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
        },
      },
      cpp = {
        {
          name = "Launch file",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
          MIMode = debugger_mode,
          miDebuggerPath = debugger_path,
        },
        {
          name = "Attach to lldbserver :1234",
          type = "cppdbg",
          request = "launch",
          MIMode = "lldb",
          miDebuggerServerAddress = "localhost:1234",
          miDebuggerPath = "/usr/bin/lldb",
          cwd = "${workspaceFolder}",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
        },
      },
      -- python comment,since use mason default config
      --/Users/bai.haodong/.local/share/nvim/lazy/mason-nvim-dap.nvim/lua/mason-nvim-dap/mappings/configurations.lua
      -- fold <<<{{{
      -- python = {
      --   {
      --     -- The first three options are required by nvim-dap
      --     type = "python", -- the type here established the link to the adapter definition: `dap.adapters.python`
      --     request = "launch",
      --     name = "Launch file",
      --
      --     -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options
      --
      --     program = function()
      --       return vim.fn.expand("%:p")
      --     end, -- Launch the current buffer file without prompting.
      --     pythonPath = function()
      --       -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
      --       -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
      --       -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
      --       local conda = os.getenv("CONDA_PREFIX")
      --       if conda and vim.fn.executable(conda .. "/bin/python") == 1 then
      --         return conda .. "/bin/python"
      --       end
      --       -- fallback to project venvs
      --       -- local cwd = vim.fn.getcwd()
      --       -- if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
      --       --   return cwd .. "/venv/bin/python"
      --       -- elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
      --       --   return cwd .. "/.venv/bin/python"
      --       -- else
      --       --   return "/usr/bin/python"
      --       -- end
      --     end,
      --   },
      -- },
      --  fold <<<}}}
    }

    -- Dap UI

    ui.setup()

    dap.listeners.before.attach.dapui_config = function()
      ui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      ui.open()
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
    map("n", "<Leader>du", ui.toggle, { desc = "DAP UI: Toggle" })

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

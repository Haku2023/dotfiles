return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = function(_, opts)
    require("claudecode").setup(opts)

    -- Let <Esc> leave terminal (insert) mode in the Claude pane. By default the
    -- key is passed straight through to the `claude` CLI. We scope the mapping to
    -- the Claude terminal buffer so other terminals keep their normal behavior.
    -- NOTE: single <Esc> then no longer reaches Claude (it uses Esc to interrupt).
    -- Swap to "<Esc><Esc>" below if you'd rather keep a single Esc for Claude.
    vim.api.nvim_create_autocmd("TermOpen", {
      pattern = "term://*claude*",
      callback = function(args)
        vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], {
          buffer = args.buf,
          desc = "Exit terminal mode (Claude)",
        })
      end,
    })
  end,
  -- `cmd` lets lazy.nvim create command stubs that load the plugin on first use,
  -- so `:ClaudeCode` and friends work on a fresh start. Without it, a keys-only
  -- spec defers loading until a <leader>a* mapping is pressed and the commands
  -- would not exist yet.
  cmd = {
    "ClaudeCode",
    "ClaudeCodeFocus",
    "ClaudeCodeSelectModel",
    "ClaudeCodeAdd",
    "ClaudeCodeSend",
    "ClaudeCodeTreeAdd",
    "ClaudeCodeStatus",
    "ClaudeCodeStart",
    "ClaudeCodeStop",
    "ClaudeCodeOpen",
    "ClaudeCodeClose",
    "ClaudeCodeDiffAccept",
    "ClaudeCodeDiffDeny",
    "ClaudeCodeCloseAllDiffs",
  },

  opts = {
    -- Server Configuration
    port_range = { min = 10000, max = 65535 },
    auto_start = true,
    log_level = "info", -- "trace", "debug", "info", "warn", "error"
    terminal_cmd = nil, -- Custom terminal command (default: "claude")
    -- For local installations: "~/.claude/local/claude"
    -- For native binary: use output from 'which claude'

    -- Send/Focus Behavior
    -- When true, successful sends focus the in-editor Claude terminal if already
    -- connected. NOTE: this only works for in-editor providers (snacks/native);
    -- it has no effect with provider = "none"/"external" (Claude runs outside
    -- Neovim). For those, hook the `User ClaudeCodeSendComplete` event (see Events).
    focus_after_send = false,

    -- Selection Tracking
    track_selection = true,
    visual_demotion_delay_ms = 50,

    -- Terminal Configuration
    terminal = {
      split_side = "right", -- "left" or "right"
      split_width_percentage = 0.50,
      -- Optional: shrink (or widen) the terminal while a diff is open. Defaults to
      -- split_width_percentage when unset, preserving today's behavior.
      diff_split_width_percentage = nil, -- e.g. 0.20 to give diffs more room
      -- Force the snacks provider so the floating layout below applies (the "auto"
      -- default could fall back to the native split, which ignores snacks_win_opts).
      provider = "snacks", -- "auto", "snacks", "native", "external", "none", or custom provider table
      auto_close = true,
      -- Auto-enter insert/terminal mode whenever the Claude terminal window gains
      -- focus. Set to false to stay in Normal mode and preserve your scroll position
      -- when switching back to the terminal (e.g. via <C-w>l); press `i` to type.
      -- Note: false also opens the terminal in Normal mode (it gates start-insert too).
      auto_insert = false,
      -- Right-docked panel with a modern rounded border. Passed straight to
      -- `Snacks.terminal.open()`.
      snacks_win_opts = {
        position = "float",
        width = 0.99,
        height = 0.99,
        border = "rounded",
        title = " Claude Code ",
        title_pos = "center",
        -- The nvim session *behind* the float: paint it absolutely black.
        -- blend = 0 => fully opaque (winblend 0), bg = pure black. Raise blend
        -- (e.g. 40) if you'd rather let the editor show through a little.
        backdrop = { bg = "#282c34", blend = 0 },
        -- Match the main editor background instead of the dimmer NormalFloat.
        -- If your colorscheme sets Normal bg = NONE (transparent), the Claude
        -- window inherits that transparency for free.
        wo = {
          winhighlight = table.concat({
            "Normal:Normal",
            "NormalFloat:Normal",
            "FloatBorder:FloatBorder",
            "FloatTitle:FloatTitle",
            "SignColumn:Normal",
          }, ","),
        },
      },
      -- Work around a Neovim core bug (< 0.12.2) that fragments large pastes into
      -- the terminal, making Cmd+V appear to truncate ([#161]). true | false | "auto"
      -- ("auto", the default, enables it only on affected Neovim versions).
      fix_streamed_paste = "auto",

      -- Provider-specific options
      provider_opts = {
        -- Command for external terminal provider. Can be:
        -- 1. String with %s placeholder: "alacritty -e %s" (backward compatible)
        -- 2. String with two %s placeholders: "alacritty --working-directory %s -e %s" (cwd, command)
        -- 3. Function returning command: function(cmd, env) return "alacritty -e " .. cmd end
        external_terminal_cmd = nil,
      },
    },

    -- Diff Integration
    diff_opts = {
      layout = "vertical", -- "vertical" (default), "horizontal", or "unified"
      -- "unified": VS Code-style unified diff in a single buffer with deleted
      --   (red/strikethrough) and added (green) lines interleaved. Requires
      --   Neovim >= 0.9.0. Highlight groups are customizable: ClaudeCodeInlineDiffAdd,
      --   ClaudeCodeInlineDiffDelete, ClaudeCodeInlineDiffAddSign, ClaudeCodeInlineDiffDeleteSign.
      open_in_new_tab = false,
      keep_terminal_focus = false, -- If true, moves focus back to terminal after diff opens
      hide_terminal_in_new_tab = false,
      auto_resize_terminal = true, -- Let the plugin manage the terminal width across the diff lifecycle; set false to own it via the User autocmds below
      -- on_new_file_reject = "keep_empty", -- "keep_empty" or "close_window"

      -- Legacy aliases (still supported):
      -- vertical_split = true,
      -- open_in_current_tab = true,
    },
  },
  keys = {
    -- { "<leader>a", nil, desc = "AI/Claude Code" },
    -- { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
    -- { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
    -- { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    -- { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    -- { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
    -- { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    -- { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
    -- {
    --   "<leader>as",
    --   "<cmd>ClaudeCodeTreeAdd<cr>",
    --   desc = "Add file",
    --   ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
    -- },
    -- Diff management
    -- { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    -- { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  },
}

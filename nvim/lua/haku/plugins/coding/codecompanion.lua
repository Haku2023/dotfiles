return {
  "olimorris/codecompanion.nvim",
  version = "^19.0.0",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    interactions = {
      chat = {
        -- adapter = "claude_code", -- ACP adapter (chat only)
        adapter = "codex", -- ACP adapter (chat only)
        keymaps = {
          regenerate = false, -- Free gr for your custom resume mapping
          change_adapter = {
            modes = { n = "<C-a>" },
          },
          debug = { modes = { n = "gm" }, opts = { silent = true } },
          send = {
            modes = { i = "<C-s>" },
            opts = {},
          },
          close = {
            modes = { n = "qq", i = "<C-c>" },
            opts = {},
          },
          -- Add further custom keymaps here
          --
          resume = {
            modes = { n = "gr" },
            description = "Resume an ACP session",
            -- callback = function(chat)
            --   local config = require("codecompanion.config")
            --   local commands = require("codecompanion.interactions.chat.slash_commands")
            --
            --   commands.new():execute({
            --     label = "/resume",
            --     config = config.interactions.chat.slash_commands.resume,
            --     context = chat.buffer_context,
            --   }, chat)
            -- end,

            callback = function(chat)
              local config = require("codecompanion.config")
              local commands = require("codecompanion.interactions.chat.slash_commands")
              local resume = require("codecompanion.interactions.chat.slash_commands.builtin.resume")

              local connection = chat.acp_connection
              if connection and not connection:is_ready() then
                vim.notify("Adapter is still connecting. Try gr again shortly.", vim.log.levels.WARN)
                return
              end

              local enabled, reason = resume.enabled(chat)
              if not enabled then
                vim.notify(("Resume unavailable for %s: %s"):format(chat.adapter.name, reason), vim.log.levels.WARN)
                return
              end

              commands.new():execute({
                label = "/resume",
                config = config.interactions.chat.slash_commands.resume,
                context = chat.buffer_context,
              }, chat)
            end,
          },
        },
      },
      inline = {
        adapter = "anthropic", -- HTTP adapter (inline supported)
      },
      cmd = {
        adapter = "anthropic",
      },
    },

    adapters = {

      acp = {
        opts = {
          show_presets = false,
        },
        codex = function()
          return require("codecompanion.adapters").extend("codex", {
            defaults = {
              auth_method = "chat-gpt", -- "openai-api-key"|"codex-api-key"|"chatgpt"
              -- model = "gpt-5.5",
              -- model_reasoning_effort = "high",
            },
            env = {},
          })
        end,
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {
            commands = {
              -- review mode: uses ~/.claude-nvim (no defaultMode), so each edit
              -- is proposed for approval. Terminal `claude` keeps using ~/.claude.
              default = {
                "env",
                "CLAUDE_CONFIG_DIR=" .. vim.fn.expand("~/.claude-nvim"),
                "claude-agent-acp",
              },
            },
            env = {
              -- BETTER: set this via environment variable instead of hardcoding
            },
            defaults = {
              -- model = "Default",
            },
          })
        end,
        gemini_cli = function()
          return require("codecompanion.adapters").extend("gemini_cli", {
            defaults = {
              auth_method = "oauth-personal", -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
            },
            env = {
              -- GEMINI_API_KEY = "cmd:op read op://personal/Gemini_API/credential --no-newline",
            },
          })
        end,
      },
      http = {
        opts = {
          show_presets = false,
        },
      },
    },
  },
  -- Optional: override the default session_list method for the codex/claude_code adapter
  -- For real path matching rather than lower case string matching for resume
  config = function(_, opts)
    require("codecompanion").setup(opts)

    local Connection = require("codecompanion.acp")
    local original_session_list = Connection.session_list

    function Connection:session_list(list_opts)
      -- Keep the default behavior for other adapters.
      if self.adapter.name ~= "codex" and self.adapter.name ~= "claude_code" then
        return original_session_list(self, list_opts)
      end

      if not self:is_ready() then
        return {}
      end

      local current = vim.uv.fs_stat(vim.fn.getcwd())
      if not current then
        return original_session_list(self, list_opts)
      end

      local limit = (list_opts and list_opts.max_sessions) or 500
      local sessions, seen_cursors = {}, {}
      local cursor

      repeat
        -- Omit cwd so the adapter doesn't filter by capitalization.
        local params = {}
        if cursor then
          params.cursor = cursor
        end

        local result = self:send_rpc_request(self.METHODS.SESSION_LIST, params)
        if not result then
          break
        end

        for _, session in ipairs(result.sessions or {}) do
          local stat = type(session.cwd) == "string" and vim.uv.fs_stat(session.cwd)

          if stat and stat.type == "directory" and stat.dev == current.dev and stat.ino == current.ino then
            sessions[#sessions + 1] = session
            if #sessions >= limit then
              return sessions
            end
          end
        end

        cursor = type(result.nextCursor) == "string" and result.nextCursor or nil

        if cursor and seen_cursors[cursor] then
          break
        end
        if cursor then
          seen_cursors[cursor] = true
        end
      until not cursor

      return sessions
    end
  end,
  --
  keys = {
    {
      "<leader>a",
      "<cmd>CodeCompanionChat Toggle<cr>",
      mode = { "n", "v" },
      desc = "Toggle CodeCompanion Chat",
    },
  },
}

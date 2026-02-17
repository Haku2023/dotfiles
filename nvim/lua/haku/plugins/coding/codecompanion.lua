return {
  "olimorris/codecompanion.nvim",
  version = "^18.0.0",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    interactions = {
      chat = {
        adapter = "claude_code", -- ACP adapter (chat only)
        -- adapter = "codex", -- ACP adapter (chat only)
        keymaps = {
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
        codex = function()
          return require("codecompanion.adapters").extend("codex", {
            defaults = {
              auth_method = "chatgpt", -- "openai-api-key"|"codex-api-key"|"chatgpt"
            },
            env = {},
          })
        end,
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {
            env = {
              -- BETTER: set this via environment variable instead of hardcoding
            },
            defaults = {
              model = "Default",
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
    },
  },
}

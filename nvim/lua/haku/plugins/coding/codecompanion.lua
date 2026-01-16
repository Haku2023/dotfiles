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
        keymaps = {
          send = {
            modes = { i = "<C-s>" },
            opts = {},
          },
          close = {
            modes = { n = "qq" },
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
              auth_method = "openai-api-key", -- "openai-api-key"|"codex-api-key"|"chatgpt"
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
              model = "opus",
            },
          })
        end,
      },
    },
  },
}

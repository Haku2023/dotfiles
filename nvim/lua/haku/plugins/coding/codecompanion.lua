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
            env = {
              -- OPENAI_API_KEY = "my-api-key",
            },
          })
        end,
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {
            env = {
              -- BETTER: set this via environment variable instead of hardcoding
              -- CLAUDE_CODE_OAUTH_TOKEN = "kQNCk0zor2PZXFDVYxEkKBUGuUo2hNxY4rX3aAEHZ48mTFFF#KnzAR7mk5q9Or3K0fq54H-9nMXTa1CwdjNdyjXnY_a4",
            },
          })
        end,
      },
      -- You *don't* have to define anthropic here unless you want to override defaults.
      -- Just ensure ANTHROPIC_API_KEY is set in your environment.
    },
  },
}

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
            modes = { n = "<C-s>", i = "<C-s>" },
            opts = {},
          },
          close = {
            modes = { n = "qq", i = "qq" },
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
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {
            env = {
              -- BETTER: set this via environment variable instead of hardcoding
              CLAUDE_CODE_OAUTH_TOKEN = "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",
            },
          })
        end,
      },
      -- You *don't* have to define anthropic here unless you want to override defaults.
      -- Just ensure ANTHROPIC_API_KEY is set in your environment.
    },
  },
}

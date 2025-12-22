-- return {
--   "olimorris/codecompanion.nvim",
--   version = "^18.0.0",
--   opts = {},
--   dependencies = {
--     "nvim-lua/plenary.nvim",
--     "nvim-treesitter/nvim-treesitter",
--   },
--   config = function()
--     require("codecompanion").setup({
--       -- Use Claude Code (ACP) for chat
--       strategies = {
--         chat = { adapter = "acp.claude_code" },
--       },
--
--       -- Use an HTTP adapter for inline (pick one you actually have working)
--       interactions = {
--         inline = { adapter = "anthropic" }, -- or "openai", or "copilot", etc.
--       },
--       -- default_adapter = "acp.claude_code",
--       adapters = {
--         acp = {
--           claude_code = function()
--             return require("codecompanion.adapters").extend("claude_code", {
--               env = {
--                 -- CLAUDE_CODE_OAUTH_TOKEN = "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",
--                 CLAUDE_CODE_OAUTH_TOKEN = "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",
--               },
--             })
--           end,
--         },
--       },
--       -- strategies = {
--       --   chat = {
--       --
--       --     adapter = "anthropic",
--       --     model = "claude-sonnet-4-20250514",
--       --     -- adapter = "claude_code",
--       --   },
--       --   inline = {
--       --     adapter = "claude_code",
--       --   },
--       --   cmd = {
--       --     adapter = "claude_code",
--       --   },
--       -- },
--     })
--   end,
-- }

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

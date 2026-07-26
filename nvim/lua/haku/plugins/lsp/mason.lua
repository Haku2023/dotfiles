return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    -- mason ships no clangd build for linux/arm64 ("The current platform is
    -- unsupported"), which is the dotbox container. There clangd comes from apt
    -- (see container/Containerfile), so ask mason for it everywhere else only.
    local uname = vim.uv.os_uname()
    local system_clangd = uname.sysname == "Linux"
      and (uname.machine == "aarch64" or uname.machine == "arm64")

    local servers = {
      "ts_ls",
      "html",
      "cssls",
      "tailwindcss",
      "svelte",
      "lua_ls",
      "graphql",
      "emmet_ls",
      "prismals",
      "pyright",
      "eslint",
      "fortls",
      "bashls",
      "texlab",
      "neocmake",
    }
    if not system_clangd then
      table.insert(servers, "clangd")
    else
      -- Not mason-managed here, so enable the PATH one ourselves.
      vim.lsp.enable("clangd")
    end

    mason_lspconfig.setup({
      -- list of servers for mason to install
      ensure_installed = servers,
      -- auto-install configured servers (with lspconfig)
      automatic_installation = true, -- not the same as ensure_installed
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        -- "isort", -- python formatter
        -- "pylint",
        "ruff", -- python formatter/linter (replaces black)
        "eslint_d",
        "fprettify",
        "shellcheck",
        "clang-format",
        "cpplint",
        "cmakelang",
      },
    })
  end,
}

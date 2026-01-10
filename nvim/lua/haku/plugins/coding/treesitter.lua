return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    if vim.loop.os_uname().sysname == "Windows_NT" then
      require("nvim-treesitter.install").compilers = { "zig" }
    end
    -- import nvim-treesitter plugin
    local treesitter = require("nvim-treesitter.configs")

    -- configure treesitter
    -- enable autotagging (w/ nvim-ts-autotag plugin)
    -- require('nvim-ts-autotag').setup({ -- enable syntax highlighting
    treesitter.setup({ -- enable syntax highlighting
      highlight = {
        enable = true,
        -- also use the legacy regex highlighter for Fortran
        additional_vim_regex_highlighting = { "fortran" },
        -- disable tree-sitter for namelist files to avoid & errors
        disable = { "namelist" },
      },

      -- enable indentation
      indent = { enable = true, disable = { "fortran", "namelist" } },
      -- ensure these language parsers are installed
      --
      ensure_installed = {
        "python",
        "powershell",
        "json",
        "javascript",
        "typescript",
        "tsx",
        "yaml",
        "html",
        "css",
        "fortran",
        "prisma",
        "markdown",
        "markdown_inline",
        "svelte",
        "graphql",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "vimdoc",
        "c",
      },
      incremental_selection = {
        enable = true,
        -- set keymaps
        keymaps = {
          init_selection = "<leader>ww",
          node_incremental = "<leader>ww",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })

    -- use bash parser for zsh files
    vim.treesitter.language.register("bash", "zsh")
    vim.treesitter.language.register("html", "htmldjango")

    -- Don't use tree-sitter for namelist files (causes errors with & syntax)
    -- vim.treesitter.language.register("fortran", "namelist")

    vim.filetype.add({
      extension = {
        ejs = "html",
        fypp = "fortran",
        -- .nml is NOT Fortran source -> different filetype
        nml = "namelist",
      },
    })

    -- disable treesitter fortran to use lsp fortls
    -- fortran omp and fortran directive
    -- vim.api.nvim_set_hl(0, "fortranDirective", { fg = "#82d600", bold = true })
    -- vim.api.nvim_create_autocmd("FileType", {
    --   pattern = { "fortran" },
    --   callback = function()
    --     vim.fn.matchadd("fortranDirective", "^#.*")
    --   end,
    -- })

    vim.api.nvim_set_hl(0, "OmpDirective", { fg = "#ffaa00", bold = true })

    -- Track which windows have OMP highlighting
    local omp_windows = {}
    vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
      pattern = "*",
      callback = function(ev)
        if vim.bo[ev.buf].filetype ~= "fortran" then
          return
        end
        if vim.w.omp_match_id then
          return
        end -- window-local guard

        -- window-local match, without polluting jumplist or search register
        vim.cmd([[
      silent! keepjumps keeppatterns
        let w:omp_match_id = matchadd('OmpDirective', '^!\$.*')
    ]])
      end,
    })

    -- optional cleanup when leaving the window/buffer
    vim.api.nvim_create_autocmd({ "BufWinLeave", "WinClosed" }, {
      callback = function()
        local id = vim.w.omp_match_id
        if id then
          pcall(vim.fn.matchdelete, id)
          vim.w.omp_match_id = nil
        end
      end,
    })

    -- vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
    --   pattern = "*",
    --   callback = function()
    --     if vim.bo.filetype == "fortran" then
    --       local win_id = vim.api.nvim_get_current_win()
    --       -- Only add match if this window hasn't been marked yet
    --       if not omp_windows[win_id] then
    --         vim.fn.matchadd("OmpDirective", "^!\\$.*")
    --         omp_windows[win_id] = true
    --       end
    --     end
    --   end,
    -- })

    -- Clean up tracking when window closes
    vim.api.nvim_create_autocmd("WinClosed", {
      callback = function(args)
        local win_id = tonumber(args.match)
        if win_id then
          omp_windows[win_id] = nil
        end
      end,
    })

    -- vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "ColorScheme" }, {
    --   pattern = "fortran",
    --   callback = function()
    --     vim.api.nvim_set_hl(0, "@variable.fortran", { fg = "NONE", bg = "NONE" })
    --   end,
    -- })

    -- Custom syntax highlighting for namelist files
    vim.api.nvim_set_hl(0, "NamelistGroup", { fg = "#82d600", bold = true })

    vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
      pattern = "namelist",
      callback = function()
        -- Comments have highest priority (priority 10)
        vim.fn.matchadd("Comment", "!.*$", 10)
        vim.fn.matchadd("Comment", "#.*$", 10)
        -- Highlight &namelist_group lines (priority -1, lower than default)
        vim.fn.matchadd("NamelistGroup", "^&\\w\\+", -1)
        -- Highlight end of namelist (/)
        vim.fn.matchadd("NamelistGroup", "^/", -1)
        -- Highlight strings (quoted text) - higher priority (11) to prevent numbers inside strings from being highlighted
        vim.fn.matchadd("String", '"[^"]*"', 5)
        vim.fn.matchadd("String", "'[^']*'", 5)
        -- Highlight numbers - link to standard Number
        vim.fn.matchadd("Number", "\\<\\d\\+\\>", -1)
        vim.fn.matchadd("Number", "\\<\\d\\+\\.\\d\\+\\>", -1)
        vim.fn.matchadd("Number", "\\<\\d\\+[eE][+-]\\?\\d\\+\\>", -1)
        vim.fn.matchadd("Number", "\\<\\d\\+\\.\\d\\+[eE][+-]\\?\\d\\+\\>", -1)
        -- Highlight Fortran double precision numbers (d/D suffix)
        vim.fn.matchadd("Number", "\\<\\d\\+\\.\\d\\+[dD][+-]\\?\\d\\+\\>", -1)
        vim.fn.matchadd("Number", "\\<\\d\\+[dD][+-]\\?\\d\\+\\>", -1)
        -- Highlight operators - link to standard Operator
        vim.fn.matchadd("Operator", "=", -1)
        vim.fn.matchadd("Operator", ",", -1)
      end,
    })
  end,
}

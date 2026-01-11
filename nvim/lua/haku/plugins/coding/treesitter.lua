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

    -- Fortran OpenMP and preprocessor directive highlighting
    -- fold <<<{{{
    vim.api.nvim_set_hl(0, "fortranDirective", { fg = "#82d600", bold = true })
    vim.api.nvim_set_hl(0, "fortranOpenMP", { fg = "#ffaa00", bold = true })

    -- Function to add Fortran matches to current window
    local function add_fortran_matches()
      -- Only proceed if current buffer is Fortran
      if vim.bo.filetype ~= "fortran" then
        return
      end

      -- Check if matches already exist for this window
      if vim.w.fortran_omp_match_id and vim.w.fortran_dir_match_id then
        return
      end

      -- Add matches with high priority to override Treesitter's @comment
      -- Use silent! keepjumps keeppatterns to avoid polluting jumplist
      vim.cmd([[
        silent! keepjumps keeppatterns
          let w:fortran_omp_match_id = matchadd('fortranOpenMP', '^\s*!\$.*', 200)
      ]])
      vim.cmd([[
        silent! keepjumps keeppatterns
          let w:fortran_dir_match_id = matchadd('fortranDirective', '^\s*#.*', 200)
      ]])
    end

    vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
      callback = add_fortran_matches,
    })

    -- Cleanup when leaving window or closing buffer
    vim.api.nvim_create_autocmd({ "BufWinLeave", "WinClosed" }, {
      callback = function()
        if vim.w.fortran_omp_match_id then
          pcall(vim.fn.matchdelete, vim.w.fortran_omp_match_id)
          vim.w.fortran_omp_match_id = nil
        end
        if vim.w.fortran_dir_match_id then
          pcall(vim.fn.matchdelete, vim.w.fortran_dir_match_id)
          vim.w.fortran_dir_match_id = nil
        end
      end,
    })
    -- fold <<<}}}

    -- Namelist filetype syntax highlighting
    -- fold <<<{{{
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
    --- fold >>>}}}
  end,
}

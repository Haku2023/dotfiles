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
        -- additional_vim_regex_highlighting = { "fortran" },
        additional_vim_regex_highlighting = false,
        -- disable tree-sitter for namelist files to avoid & errors
        -- disable = { "namelist" },
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
        "cpp",
        "latex",
      },
      incremental_selection = {
        enable = true,
        -- set keymaps
        keymaps = {
          init_selection = "<leader>ww",
          node_incremental = "<leader>ww",
          scope_incremental = false,
          node_decremental = "<leader>wh",
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

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "codecompanion",
      callback = function(ev)
        vim.keymap.set("n", "gd", "<Nop>", { buffer = ev.buf, silent = true })
      end,
    })

    -- Custom highlights for Fortran directives and OpenMP
    -- fold <<<{{{
    vim.api.nvim_set_hl(0, "fortranDirective", { fg = "#82d600", bold = true })
    vim.api.nvim_set_hl(0, "fortranOpenMP", { fg = "#ffaa00", bold = true })
    vim.api.nvim_set_hl(0, "@punctuation.special.fortran", { fg = "#ff8700", bold = true })
    vim.api.nvim_set_hl(0, "@operator.pointer.fortran", { fg = "#af87ff", bold = true })
    -- Function to add fortran matches to current window
    local function add_fortran_matches()
      -- Only proceed if current buffer is fortran
      if vim.bo.filetype ~= "fortran" then
        return
      end

      -- Clear existing matches if they exist to avoid duplicates
      if vim.w.fortran_matches then
        for _, match_id in ipairs(vim.w.fortran_matches) do
          pcall(vim.fn.matchdelete, match_id)
        end
      end
      vim.w.fortran_matches = {}

      table.insert(vim.w.fortran_matches, vim.fn.matchadd("fortranOpenMP", "^\\s*!\\$.*", -1))
      table.insert(vim.w.fortran_matches, vim.fn.matchadd("fortranDirective", "^\\s*#.*", -1))
    end

    -- Apply matches when entering a fortran buffer/window
    vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
      callback = function()
        if vim.bo.filetype == "fortran" then
          add_fortran_matches()
        end
      end,
    })

    -- Cleanup when leaving window
    vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
      callback = function()
        if vim.w.fortran_matches then
          for _, match_id in ipairs(vim.w.fortran_matches) do
            pcall(vim.fn.matchdelete, match_id)
          end
          vim.w.fortran_matches = nil
        end
      end,
    })
    --- fold >>>}}}

    -- Namelist filetype syntax highlighting
    -- fold <<<{{{
    vim.api.nvim_set_hl(0, "NamelistGroup", { fg = "#82d600", bold = true })

    -- Function to add namelist matches to current window
    local function add_namelist_matches()
      -- Only proceed if current buffer is namelist
      if vim.bo.filetype ~= "namelist" then
        return
      end

      -- Clear existing matches if they exist to avoid duplicates
      if vim.w.namelist_matches then
        for _, match_id in ipairs(vim.w.namelist_matches) do
          pcall(vim.fn.matchdelete, match_id)
        end
      end
      vim.w.namelist_matches = {}

      -- Add matches and store their IDs
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("Comment", "!.*$", 10))
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("Comment", "#.*$", 10))
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("NamelistGroup", "^&\\w\\+", -1))
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("NamelistGroup", "^/", -1))
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("String", '"[^"]*"', 5))
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("String", "'[^']*'", 5))
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("Number", "\\<\\d\\+\\>", -1))
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("Number", "\\<\\d\\+\\.\\d\\+\\>", -1))
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("Number", "\\<\\d\\+[eE][+-]\\?\\d\\+\\>", -1))
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("Number", "\\<\\d\\+\\.\\d\\+[eE][+-]\\?\\d\\+\\>", -1))
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("Number", "\\<\\d\\+\\.\\d\\+[dD][+-]\\?\\d\\+\\>", -1))
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("Number", "\\<\\d\\+[dD][+-]\\?\\d\\+\\>", -1))
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("Operator", "=", -1))
      table.insert(vim.w.namelist_matches, vim.fn.matchadd("Operator", ",", -1))
    end

    -- Apply matches when entering a namelist buffer/window
    vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
      callback = function()
        if vim.bo.filetype == "namelist" then
          add_namelist_matches()
        end
      end,
    })

    -- Cleanup when leaving window
    vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
      callback = function()
        if vim.w.namelist_matches then
          for _, match_id in ipairs(vim.w.namelist_matches) do
            pcall(vim.fn.matchdelete, match_id)
          end
          vim.w.namelist_matches = nil
        end
      end,
    })
    --- fold >>>}}}
  end,
}

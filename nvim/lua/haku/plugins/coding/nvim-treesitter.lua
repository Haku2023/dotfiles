return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    if vim.loop.os_uname().sysname == "Windows_NT" then
      require("nvim-treesitter.install").compilers = { "zig" }
    else
      -- Ensure treesitter compiles parsers for arm64 (system cc is universal binary)
      require("nvim-treesitter.install").compilers = { "/usr/bin/cc" }
    end
    require("nvim-treesitter").install({
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
      "cmake",
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
    local fortran_groups = { fortranOpenMP = true, fortranDirective = true }

    local function clear_fortran_matches()
      for _, m in ipairs(vim.fn.getmatches()) do
        if fortran_groups[m.group] then
          pcall(vim.fn.matchdelete, m.id)
        end
      end
    end

    local function add_fortran_matches()
      clear_fortran_matches()
      vim.fn.matchadd("fortranOpenMP", "^\\s*!\\$.*", -1)
      vim.fn.matchadd("fortranDirective", "^\\s*#.*", -1)
    end

    -- Apply matches when entering a fortran buffer/window, clean up otherwise
    vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "WinEnter" }, {
      callback = function()
        if vim.bo.filetype == "fortran" then
          add_fortran_matches()
        else
          clear_fortran_matches()
        end
      end,
    })
    --- fold >>>}}}

    -- Namelist filetype syntax highlighting
    -- fold <<<{{{
    vim.api.nvim_set_hl(0, "NamelistGroup", { fg = "#82d600", bold = true })

    -- Use IDs in a reserved range (1100-1199) to identify namelist matches
    local namelist_id_start = 1100
    local namelist_id_end = 1199

    local function clear_namelist_matches()
      for _, m in ipairs(vim.fn.getmatches()) do
        if m.id >= namelist_id_start and m.id <= namelist_id_end then
          pcall(vim.fn.matchdelete, m.id)
        end
      end
    end

    local function add_namelist_matches()
      clear_namelist_matches()
      local id = namelist_id_start
      local function nml_match(group, pattern, priority)
        vim.fn.matchadd(group, pattern, priority, id)
        id = id + 1
      end
      nml_match("Comment", "!.*$", 10)
      nml_match("Comment", "#.*$", 10)
      nml_match("NamelistGroup", "^&\\w\\+", -1)
      nml_match("NamelistGroup", "^/", -1)
      nml_match("String", '"[^"]*"', 5)
      nml_match("String", "'[^']*'", 5)
      nml_match("Number", "\\<\\d\\+\\>", -1)
      nml_match("Number", "\\<\\d\\+\\.\\d\\+\\>", -1)
      nml_match("Number", "\\<\\d\\+[eE][+-]\\?\\d\\+\\>", -1)
      nml_match("Number", "\\<\\d\\+\\.\\d\\+[eE][+-]\\?\\d\\+\\>", -1)
      nml_match("Number", "\\<\\d\\+\\.\\d\\+[dD][+-]\\?\\d\\+\\>", -1)
      nml_match("Number", "\\<\\d\\+[dD][+-]\\?\\d\\+\\>", -1)
      nml_match("Operator", "=", -1)
      nml_match("Operator", ",", -1)
    end

    -- Apply matches when entering a namelist buffer/window, clean up otherwise
    vim.api.nvim_create_autocmd({ "FileType", "BufEnter", "WinEnter" }, {
      callback = function()
        if vim.bo.filetype == "namelist" then
          add_namelist_matches()
        else
          clear_namelist_matches()
        end
      end,
    })
    --- fold >>>}}}
    ---
    -- enable treesitter for all filetypes highlighting
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}

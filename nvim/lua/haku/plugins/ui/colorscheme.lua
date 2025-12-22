return {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      local bg = "#011628"
      local bg_dark = "#011423"
      local bg_highlight = "#143652"
      local bg_search = "#0A64AC"
      local bg_visual = "#275378"
      local fg = "#CBE0F0"
      local fg_dark = "#B4D0E9"
      local fg_gutter = "#627E97"
      local border = "#547998"
      --haku check
      -- local colors = require("tokyonight.colors").setup()
      -- print(vim.inspect(colors))

      require("tokyonight").setup({
        -- fold <<<-- {{{
        style = "moon",
        transparent = true,
        styles = {
          sidebars = "transparent",
          float = "transparent",
        },

        -- transparent telescope including fzf
        on_highlights = function(hl, c)
          local prompt = "#CBE0F0"
          hl.TelescopeNormal = {
            -- bg = c.bg_dark,
            fg = prompt,
          }
          hl.TelescopeBorder = {
            -- bg = c.bg_dark,
            -- fg = c.bg_dark,
            fg = prompt,
          }
          hl.TelescopePromptNormal = {
            -- bg = prompt,
          }
          hl.TelescopePromptBorder = {
            -- bg = prompt,
            fg = prompt,
          }
          hl.TelescopePromptTitle = {
            -- bg = prompt,
            fg = prompt,
          }
          hl.TelescopePreviewTitle = {
            -- bg = c.bg_dark,
            -- fg = c.bg_dark,
            fg = prompt,
          }
          hl.TelescopeResultsTitle = {
            -- bg = c.bg_dark,
            -- fg = c.bg_dark,
            fg = prompt,
          }
          hl.String = { fg = c.green }
          hl["@constructor"] = { fg = c.green1 }
          -- hl.String = { fg = "#FEE2AD" }
          hl["@variable"] = { fg = c.orange, bold = false }
          hl["@variable.member"] = { fg = c.teal }
          hl["@property"] = { fg = c.teal }
          -- hl["@keyword"] = { italic = false, bold = true, fg = "#FFD369" }
          hl["@keyword"] = { italic = false, bold = true, fg = c.magenta }
          hl["Function"] = { bold = false, fg = c.yellow, italic = true }
        end,
        -- transparent colorscheme tokyonight
        on_colors = function(colors)
          colors.bg = bg
          colors.bg_dark = bg_dark
          colors.bg_float = bg_dark
          colors.bg_highlight = bg_highlight
          colors.bg_popup = bg_dark
          colors.bg_search = bg_search
          colors.bg_sidebar = bg_dark
          colors.bg_statusline = bg_dark
          colors.bg_visual = bg_visual
          colors.border = border
          colors.fg = fg
          colors.fg_dark = fg_dark
          colors.fg_float = fg
          colors.fg_gutter = fg_gutter
          colors.fg_sidebar = fg_dark
          -- colors.comment = "#93DA97"
          colors.comment = "#a4aacb"

          -- colors.comment = colors.comment
        end,
      })
      --fold <<< -- }}}

      -- vim.cmd("colorscheme tokyonight")
    end,
  },

  {
    "loctvl842/monokai-pro.nvim",
    priority = 1000,
    config = function()
      require("monokai-pro").setup({
        transparent_background = true,
        terminal_colors = true,
        devicons = true, -- highlight the icons of `nvim-web-devicons`
        styles = {
          comment = { italic = true, fg = "#a4aacb" },
          keyword = { italic = true }, -- any other keyword
          type = { italic = true }, -- (preferred) int, long, char, etc
          storageclass = { italic = true }, -- static, register, volatile, etc
          structure = { italic = true }, -- struct, union, enum, etc
          parameter = { italic = true }, -- parameter pass in function
          annotation = { italic = true },
          tag_attribute = { italic = true }, -- attribute of tag in reactjs
        },
        filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
        -- Enable this will disable filter option
        day_night = {
          enable = false, -- turn off by default
          day_filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
          night_filter = "spectrum", -- classic | octagon | pro | machine | ristretto | spectrum
        },
        inc_search = "background", -- underline | background
        background_clear = {
          -- "float_win",
          "toggleterm",
          "telescope",
          "which-key",
          "renamer",
          "notify",
          "nvim-tree",
          -- "neo-tree",
          "bufferline", -- better used if background of `neo-tree` or `nvim-tree` is cleared
        }, -- "float_win", "toggleterm", "telescope", "which-key", "renamer", "neo-tree", "nvim-tree", "bufferline"
        plugins = {
          bufferline = {
            underline_selected = false,
            underline_visible = false,
          },
          indent_blankline = {
            context_highlight = "default", -- default | pro
            context_start_underline = false,
          },
        },
        -- ---@param c Colorscheme
        -- override = function(c) end,
        -- ---@param cs Colorscheme
        -- ---@param p ColorschemeOptions
        -- ---@param Config MonokaiProOptions
        -- ---@param hp Helper
        -- override = function(cs: Colorscheme, p: ColorschemeOptions, Config: MonokaiProOptions, hp: Helper) end,
        --
        --
        -- ...
        --- @param filter "classic" | "machine" | "octagon" | "pro" | "ristretto" | "spectrum"
        overridePalette = function(filter)
          return {
            -- dark2 = "#101014",
            -- dark1 = "#16161E",
            -- background = "#1A1B26",
            -- text = "#C0CAF5",
            -- accent1 = "#f7768e",
            -- accent2 = "#7aa2f7",
            -- accent3 = "#e0af68",
            -- accent4 = "#9ece6a",
            -- accent5 = "#0DB9D7",
            -- accent6 = "#9d7cd8",
            -- dimmed1 = "#e0af68",
            -- light blue
            -- dimmed2 = "#90a4ff",
            dimmed2 = "#c0c0c0",

            -- dimmed3 = "#363b54",
            -- dimmed4 = "#363b54",
            -- dimmed5 = "#16161e",
          }
        end,
        -- ...
        -- ...
        override = function(c)
          return {
            -- Normal = { bg = "#000000" },
            IndentBlanklineChar = { fg = c.base.dimmed4 },
            Comment = { fg = c.base.dimmed2 },
            -- colors.comment = "#93DA97"
            -- colors.comment = "#a4aacb"
          }
        end,
        -- ...
      })
      vim.cmd("colorscheme monokai-pro-octagon")
      vim.api.nvim_set_hl(0, "@keyword.function.fortran", { fg = "#A888F8", bold = true })
      vim.api.nvim_set_hl(0, "@module.fortran", { fg = "#A888F8", bold = true })
      vim.api.nvim_set_hl(0, "@function.builtin.fortran", { fg = "#EE6188" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFA500", bold = true })
    end,
  },
}

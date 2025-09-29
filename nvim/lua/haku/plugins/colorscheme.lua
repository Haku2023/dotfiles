return {
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
    vim.cmd("colorscheme tokyonight")
  end,
}

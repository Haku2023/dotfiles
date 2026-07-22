return {
  "norcalli/nvim-colorizer.lua",
  config = function()
    require("colorizer").setup(
      -- filetypes: "*" = attach to every buffer (so .lua, .toml, etc. all preview)
      {
        "*",
        html = { mode = "foreground" },
      },
      -- default options (second arg — applies to all filetypes above)
      {
        RGB = true, -- #RGB hex codes
        RRGGBB = true, -- #RRGGBB hex codes
        names = true, -- "Name" codes like Blue
        RRGGBBAA = false, -- #RRGGBBAA hex codes
        rgb_fn = false, -- CSS rgb() and rgba() functions
        hsl_fn = false, -- CSS hsl() and hsla() functions
        css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn
        -- Available modes: foreground, background
        mode = "background", -- Set the display mode.
      }
    )
  end,
}

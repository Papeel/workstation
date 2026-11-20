-- tokyonight adaptado a la paleta de Ghostty (fondo #06080f)
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = true, -- usa el fondo (y la opacidad) de Ghostty
      styles = {
        sidebars = "transparent",
        floats = "dark",
      },
      on_colors = function(c)
        c.bg = "#06080f"
        c.bg_dark = "#0b0e17"
        c.bg_float = "#0b0e17"
        c.bg_popup = "#0b0e17"
        c.bg_sidebar = "#06080f"
        c.bg_statusline = "#0b0e17"
        c.bg_highlight = "#111626"
        c.bg_visual = "#263356"
        c.border = "#1a2033"
        c.border_highlight = "#263356"
        c.fg_gutter = "#3a3f52"
        -- acentos de la paleta de Ghostty
        c.blue = "#7fb4ca"
        c.cyan = "#a3d4d5"
        c.green = "#b7cc85"
        c.red = "#cb7c94"
        c.yellow = "#e0c15a"
        c.comment = "#6b7089"
      end,
      on_highlights = function(hl, c)
        hl.CursorLineNr = { fg = c.yellow, bold = true }
        hl.FloatBorder = { fg = c.border_highlight, bg = c.bg_float }
        hl.WinSeparator = { fg = c.border, bold = true }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "tokyonight-night" },
  },
}

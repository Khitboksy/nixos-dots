-- Core: LazyVim bootstrap + theme + line_num
return {
  -- LazyVim bootstrap
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
      news = { lazyvim = false },
    },
  },

  -- Catppuccin theme
  {
    "catppuccin",
    opts = function(_, opts)
      opts.transparent_background = true
      opts.flavour = "mocha"
      opts.integrations = vim.tbl_deep_extend("force", opts.integrations or {}, {
        blink_cmp = true,
      })
      opts.custom_highlights = function(colors)
        return {
          Normal = { bg = "NONE" },
          NormalNC = { bg = "NONE" },
          NormalFloat = { bg = "NONE" },
          FloatBorder = { fg = "NONE", bg = "NONE" },
          Pmenu = { bg = "NONE" },
          PmenuSel = { bg = "NONE" },
          StatusLine = { bg = "NONE" },
          StatusLineNC = { bg = "NONE" },
          TabLine = { bg = "NONE" },
          TabLineFill = { bg = "NONE" },
          SignColumn = { bg = "NONE" },
          LineNr = { fg = colors.overlay1 },
          CursorLine = { bg = "NONE" },
          CursorLineNr = { fg = colors.lavender },
          Visual = { bg = "NONE", fg = colors.blue, bold = true },
          NeoTreeNormal = { bg = "NONE" },
          NeoTreeNormalNC = { bg = "NONE" },
        }
      end
      return opts
    end,
  },

  -- Line number mode plugin
  { import = "plugins.line_num" },
}

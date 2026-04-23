return {
  "sethen/line-number-change-mode.nvim",
  config = function()
    -- Load colors from custom theme
    local colors = require("themes.colors")

    require("line-number-change-mode").setup({
      mode = {
        i = {
          bg = colors.green.hex,
          fg = colors.mantle.hex,
          bold = true,
        },
        n = {
          bg = colors.blue.hex,
          fg = colors.mantle.hex,
          bold = true,
        },
        R = {
          bg = colors.maroon.hex,
          fg = colors.mantle.hex,
          bold = true,
        },
        v = {
          bg = colors.mauve.hex,
          fg = colors.mantle.hex,
          bold = true,
        },
        V = {
          bg = colors.mauve.hex,
          fg = colors.mantle.hex,
          bold = true,
        },
      },
    })
  end,
}
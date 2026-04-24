return {
  "sethen/line-number-change-mode.nvim",
  config = function()
    -- Get catppuccin mocha palette
    local mocha = require("catppuccin.palettes").get_palette("mocha")

    require("line-number-change-mode").setup({
      mode = {
        i = {
          bg = mocha.green,
          fg = mocha.mantle,
          bold = true,
        },
        n = {
          bg = mocha.blue,
          fg = mocha.mantle,
          bold = true,
        },
        R = {
          bg = mocha.maroon,
          fg = mocha.mantle,
          bold = true,
        },
        v = {
          bg = mocha.mauve,
          fg = mocha.mantle,
          bold = true,
        },
        V = {
          bg = mocha.mauve,
          fg = mocha.mantle,
          bold = true,
        },
      },
    })
  end,
}
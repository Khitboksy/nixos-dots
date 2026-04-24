require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
    { import = "plugins.extras.rust" },
    { import = "lazyvim.plugins.extras.coding.yanky" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "catppuccin-mocha", "habamax" } },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

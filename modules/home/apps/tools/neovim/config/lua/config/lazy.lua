require("lazy").setup({
  spec = {
    -- 1. LazyVim base plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- 2. LazyVim extras (imported manually since lazyvim.jsonc reading approach failed)
    { import = "lazyvim.plugins.extras.coding.yanky" },
    { import = "lazyvim.plugins.extras.editor.neo-tree" },

    -- 3. Your plugins (core, lsp, ui, tools, lang/, extras/)
    { import = "plugins" },
  },
  defaults = {
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
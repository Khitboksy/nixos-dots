-- UI: snacks dashboard, statusline, indent-blankline
-- (neo-tree is handled by lazyvim.plugins.extras.editor.neo-tree)
return {
  -- snacks.nvim: dashboard + projects, zen mode
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      scroll = { enabled = false },
      explorer = { enabled = false },  -- disable snacks explorer (use neo-tree)
      dashboard = {
        preset = {
          header = [[
          ／l、             
       （ﾟ､ ｡ ７         
      l  ~ヽ       
   じしf_,)ノ
        ]],
        },
      },
      projects = {
        paths = { "~/proj", "~/projects", "~/builds" },
      },
    },
    keys = {
      {
        "<leader>z",
        function()
          Snacks.zen()
        end,
        desc = "Toggle Zen Mode",
      },
    },
  },

  -- statusline (using mini.statusline, lualine disabled)
  { "nvim-lualine/lualine.nvim", enabled = false },
  { "nvim-mini/mini.statusline", opts = {} },

  -- indent blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    tag = "v3.8.2",
  },
}
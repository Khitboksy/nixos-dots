return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
      news = { lazyvim = false },
    },
  },
  {
    "snacks.nvim",
    opts = {
      scroll = { enabled = false },
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
    },
  },
  {
    "catppuccin",
    opts = function(_, opts)
      opts.transparent_background = true
      opts.flavour = "mocha"
      opts.integrations = vim.tbl_deep_extend("force", opts.integrations or {}, {
        blink_cmp = true,
        -- Add other integrations as needed
      })
      -- Add custom highlights using your colors
      -- These match lib/theme/default.nix exactly
      opts.custom_highlights = function(colors)
        return {
          -- Transparent backgrounds
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
          -- Cursor line
          CursorLine = { bg = "NONE" },
          CursorLineNr = { fg = colors.lavender },
          -- Visual
          Visual = { bg = "NONE", fg = colors.blue, bold = true },
          -- Neo-tree
          NeoTreeNormal = { bg = "NONE" },
          NeoTreeNormalNC = { bg = "NONE" },
          -- Add any other custom highlights here
          -- Match your lib/theme colors exactly
        }
      end
      return opts
    end,
  },
  "f-person/git-blame.nvim",
  { "nvim-lualine/lualine.nvim", enabled = false },
  { "nvim-mini/mini.statusline", opts = {} },
  { import = "plugins.line_num" },
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    opts = {
      window = {
        width = 30,
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    ft = "nix",
    opts = {
      servers = {
        statix = {
          cmd = { "statix", "check", "--stdin" },
          rootMarkers = { "flake.nix", ".git" },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        nix = { "nixfmt" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        javascriptreact = { "prettierd" },
        javascript = { "prettierd" },
        htmlangular = { "prettierd" },
      },
    },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
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
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    tag = "v3.8.2",
  },
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup()
    end,
  },
  {
    "jake-stewart/force-cul.nvim",
    config = function()
      require("force-cul").setup()
    end,
  },
}
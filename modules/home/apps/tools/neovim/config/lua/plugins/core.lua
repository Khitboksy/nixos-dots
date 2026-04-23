return {
  {
    "LazyVim/LazyVim",
    config = function()
      -- Force mocha theme on startup using autocmd (more reliable than init)
      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          -- Add themes to runtime path
          vim.opt.rtp:prepend(vim.fn.stdpath("config") .. "/lua/themes")
          vim.opt.termguicolors = true

          -- Load and apply mocha theme
          local mocha_path = vim.fn.stdpath("config") .. "/lua/themes/mocha.lua"
          local mocha = dofile(mocha_path)
          mocha.setup()

          -- Explicitly set colorscheme
          vim.g.colors_name = "mocha"
          vim.cmd("colorscheme mocha")

          -- Apply transparent backgrounds
          local groups = {
            "Normal", "NormalNC", "NormalFloat", "NormalSB",
            "LineNr", "CursorLine", "CursorLineNr",
            "EndOfBuffer", "VertSplit", "SignColumn", "Folded",
            "Pmenu", "PmenuSbar", "PmenuSel", "PmenuThumb",
            "StatusLine", "StatusLineNC",
            "TabLine", "TabLineFill", "TabLineSel",
            "WinSeparator",
            "NeoTreeNormal", "NeoTreeNormalNC",
            "NeoTreeVertSplit", "NeoTreeWinSeparator",
          }
          for _, g in ipairs(groups) do
            pcall(vim.cmd, "hi " .. g .. " guibg=NONE ctermbg=NONE")
          end
        end,
      })
    end,
    opts = {
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
  "f-person/git-blame.nvim",
  { "nvim-lualine/lualine.nvim", enabled = false },
  { "nvim-mini/mini.statusline", opts = {} },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    opts = {
      formatters_by_ft = {
        nix = { "alejandra" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        javascriptreact = { "prettierd" },
        javascript = { "prettierd" },
        htmlangular = { "prettierd" },
      },
      format_on_save = true,
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
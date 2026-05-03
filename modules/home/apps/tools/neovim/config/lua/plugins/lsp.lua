-- LSP configuration: nixd, lua_ls, conform
return {
  -- nixd LSP for Nix files
  -- Minimal config to prevent multiple evaluations
  {
    "neovim/nvim-lspconfig",
    ft = "nix",
    opts = {
      servers = {
        nixd = {
          cmd = { "nixd" },
          settings = {
            nixd = {
              nixpkgs = {
                expr = "import <nixpkgs> { }",
              },
              formatting = {
                command = { "nixfmt" },
              },
            },
          },
        },
      },
    },
  },

  -- lua_ls for Lua files
  {
    "neovim/nvim-lspconfig",
    ft = "lua",
    opts = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = "Replace",
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
      },
    },
  },

  -- conform for formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        javascriptreact = { "prettierd" },
        javascript = { "prettierd" },
        htmlangular = { "prettierd" },
      },
    },
  },
}
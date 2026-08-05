-- LSP configuration: nixd, lua_ls, conform
-- Language servers and formatters are provided by dev shells, not neovim.
-- nvim-lspconfig auto-detects servers on PATH, so it only activates
-- when the relevant dev shell is active.
return {
  -- nixd LSP for Nix files (provided by nix dev shell)
  -- Formatting is handled by conform.nvim, not nixd
  {
    "neovim/nvim-lspconfig",
    ft = "nix",
    opts = {
      servers = {
        -- Disable nil_ls (LazyVim default, we use nixd instead)
        nil_ls = false,
        nixd = {
          on_init = function(client)
            client.server_capabilities.documentFormattingProvider = false
          end,
          settings = {
            nixd = {
              nixpkgs = {
                expr = "import <nixpkgs> { }",
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

  -- conform for formatting (formatters provided by dev shells)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        nix = { "treefmt" },
        rust = { "rustfmt" },
        lua = { "stylua" },
        json = { "prettierd" },
        yaml = { "prettierd" },
        toml = { "taplo" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        javascriptreact = { "prettierd" },
        javascript = { "prettierd" },
        html = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        less = { "prettierd" },
        markdown = { "prettierd" },
      },
    },
  },
}

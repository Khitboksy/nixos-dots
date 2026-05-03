-- Load custom snippets from snippets/ folder via LuaSnip
return {
  {
    "L3MON4D3/LuaSnip",
    opts = {
      -- load custom snippets from snippets/ folder
      loaders = {
        require("luasnip.loaders.from_vscode").lazy_load({
          paths = { vim.fn.stdpath("config") .. "/snippets" },
        }),
      },
    },
  },
}
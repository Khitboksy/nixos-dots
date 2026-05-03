-- Tools: better-escape, force-cul, git-blame
return {
  -- Better escape for jj/hk mappings
  {
    "max397574/better-escape.nvim",
    config = function()
      require("better_escape").setup()
    end,
  },

  -- Force-cul for cursor line highlighting
  {
    "jake-stewart/force-cul.nvim",
    config = function()
      require("force-cul").setup()
    end,
  },

  -- Git blame in gutter
  "f-person/git-blame.nvim",
}
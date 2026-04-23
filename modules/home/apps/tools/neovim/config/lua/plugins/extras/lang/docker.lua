-- LazyVim Docker language support
-- This stub provides the missing docker extra
return {
  recommended = function()
    return LazyVim.extras.wants({
      ft = "dockerfile",
      root = {
        "Dockerfile",
        "Containerfile",
        "docker-compose.yml",
        "compose.yml",
        "docker-compose.yaml",
        "compose.yaml",
      },
    })
  end,
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "dockerfile" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        dockerls = {},
        docker_compose_language_service = {},
      },
    },
  },
}
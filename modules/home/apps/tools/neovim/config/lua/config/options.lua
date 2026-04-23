-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Use 24-bit color (true color) for terminal
vim.opt.termguicolors = true

if vim.g.neovide then
  -- Put anything you want to happen only in Neovide here
  vim.o.guifont = "Helios:h14"
end

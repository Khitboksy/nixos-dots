-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Show colorcolumn at 80 for markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt.colorcolumn = "80"
  end,
})

-- Clear colorcolumn when leaving markdown
vim.api.nvim_create_autocmd("BufLeave", {
  pattern = "*.md",
  callback = function()
    vim.opt.colorcolumn = ""
  end,
})

-- Neo-tree: refresh git status on BufWritePost
local function refresh_neotree_git()
  if package.loaded["neo-tree.sources.git_status"] then
    local ok, source = pcall(require, "neo-tree.sources.git_status")
    if ok and source and source.refresh then
      source.refresh()
    end
  end
end

vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    vim.defer_fn(refresh_neotree_git, 50)
  end,
})

vim.api.nvim_create_autocmd("FocusGained", {
  callback = refresh_neotree_git,
})
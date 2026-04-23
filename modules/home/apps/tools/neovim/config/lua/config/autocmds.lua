-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Force re-apply mocha styling after all plugins load
vim.api.nvim_create_autocmd("VeryLazy", {
  callback = function()
    vim.defer_fn(function()
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
    end, 100)
  end,
})

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

-- Neo-tree: ensure window fills available space dynamically
vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function()
    local ok, _ = pcall(vim.api.nvim_buf_get_var, 0, "neo_tree_source")
    if ok then
      vim.cmd("vertical resize!")
    end
  end,
})

-- Neo-tree: resize window when Vim resizes
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ok, _ = pcall(vim.api.nvim_buf_get_var, buf, "neo_tree_source")
      if ok then
        vim.api.nvim_set_current_win(win)
        vim.cmd("vertical resize!")
        break
      end
    end
  end,
})

-- Neo-tree: fix transparent background on NeoTree events
vim.api.nvim_create_autocmd("User", {
  pattern = "NeoTree-*",
  callback = function()
    vim.cmd("hi NeoTreeNormal guibg=NONE ctermbg=NONE")
    vim.cmd("hi NeoTreeNormalNC guibg=NONE ctermbg=NONE")
  end,
})

-- Neo-tree: helper function to refresh git status
local function refresh_neotree_git()
  if package.loaded["neo-tree.sources.git_status"] then
    local ok, source = pcall(require, "neo-tree.sources.git_status")
    if ok and source and source.refresh then
      source.refresh()
    end
  end
end

-- Neo-tree: refresh on BufWritePost
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    vim.defer_fn(function()
      refresh_neotree_git()
    end, 50)
  end,
})

-- Neo-tree: refresh on FocusGained
vim.api.nvim_create_autocmd("FocusGained", {
  callback = function()
    refresh_neotree_git()
  end,
})

-- Neo-tree: watch .git directory for changes
vim.api.nvim_create_autocmd("VeryLazy", {
  callback = function()
    local git_dir = vim.fn.finddir(".git", vim.fn.getcwd())
    if git_dir == "" then return end

    local git_watcher = vim.uv.new_fs_event()

    -- Watch .git for file changes (git operations modify files there)
    local ok = pcall(function()
      git_watcher:start(git_dir, {}, function()
        refresh_neotree_git()
      end)
    end)
    if not ok then
      -- Fallback: poll .git/index every 5 seconds
      local stat_timer = vim.uv.new_timer()
      stat_timer:start(0, 5000, function()
        local git_index = git_dir .. "/index"
        if vim.uv.fs_stat(git_index) then
          refresh_neotree_git()
        end
      end)
    end
  end,
})
return {
  "NeogitOrg/neogit",
  cmd = { "Neogit" },
  keys = {
    { "<leader>ng", "<cmd>Neogit<cr>", desc = "Open Neogit" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim", -- required
    "sindrets/diffview.nvim", -- optional - Diff integration
    "nvim-telescope/telescope.nvim", -- optional
  },
  config = function(_, opts)
    -- Setup neo-tree git_status refresh after neogit commits
    local function refresh_neotree()
      vim.defer_fn(function()
        -- Refresh any open neo-tree git_status buffers
        if package.loaded["neo-tree.sources.git_status"] then
          require("neo-tree.sources.git_status").refresh()
        end
      end, 200)
    end

    -- Refresh neotree after neogit operations
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*",
      callback = function()
        -- Check if we just left a neogit buffer
        local ft = vim.bo.filetype
        if ft == "NeogitCommitView" or ft == "NeogitRebaseUpdate" or ft == "NeogitStatus" then
          refresh_neotree()
        end
      end,
    })

    -- Refresh on FocusEnter (when coming back to nvim)
    vim.api.nvim_create_autocmd("FocusGained", {
      callback = function()
        refresh_neotree()
      end,
    })
  end,
}

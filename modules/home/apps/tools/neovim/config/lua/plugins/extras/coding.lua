-- Custom blink.cmp configuration: language completions only, Enter for newline
return {
  {
    "saghen/blink.cmp",
    opts = {
      -- Only language-specific completions (no dictionary words from buffers)
      sources = {
        default = { "lsp", "path", "snippets" },
      },

      -- Tab accepts, Enter inserts newline (super-tab preset)
      keymap = {
        preset = "super-tab",
      },
    },
  },
}
{ lib }:

with lib;
with lib.custom;

''
  # Yazi Theme - Catppuccin Mocha Mauve (Helios Custom)

  [manager]
  bg = ""

  [manager.file_style]
  bold = false
  italic = false
  dim = false

  [manager.file_style.cursor]
  fg = "${colors.mauve.hex}"
  bold = true
  italic = false

  [manager.file_style.cwd]
  fg = "${colors.mauve.hex}"
  bold = true
  italic = false

  [manager.file_style.marked]
  fg = "${colors.yellow.hex}"
  bold = false
  italic = false

  [mgr]
  cwd = { fg = "${colors.mauve.hex}" }

  find_keyword  = { fg = "${colors.yellow.hex}", italic = true }
  find_position = { fg = "${colors.pink.hex}", bg = "reset", italic = true }

  marker_copied   = { fg = "${colors.green.hex}", bg = "${colors.green.hex}" }
  marker_cut      = { fg = "${colors.red.hex}", bg = "${colors.red.hex}" }
  marker_marked   = { fg = "${colors.teal.hex}", bg = "${colors.teal.hex}" }
  marker_selected = { fg = "${colors.mauve.hex}", bg = "${colors.mauve.hex}" }

  count_copied   = { fg = "${colors.base.hex}", bg = "${colors.green.hex}" }
  count_cut      = { fg = "${colors.base.hex}", bg = "${colors.red.hex}" }
  count_selected = { fg = "${colors.base.hex}", bg = "${colors.mauve.hex}" }

  border_symbol = "│"
  border_style  = { fg = "${colors.overlay1.hex}" }

  syntect_theme = "~/.config/yazi/helios.tmTheme"

  [tabs]
  active   = { fg = "${colors.base.hex}", bg = "${colors.text.hex}", bold = true }
  inactive = { fg = "${colors.text.hex}", bg = "${colors.surface1.hex}" }

  [mode]
  normal_main = { fg = "${colors.base.hex}", bg = "${colors.mauve.hex}", bold = true }
  normal_alt  = { fg = "${colors.mauve.hex}", bg = "${colors.surface0.hex}" }

  select_main = { fg = "${colors.base.hex}", bg = "${colors.green.hex}", bold = true }
  select_alt  = { fg = "${colors.green.hex}", bg = "${colors.surface0.hex}" }

  unset_main  = { fg = "${colors.base.hex}", bg = "${colors.flamingo.hex}", bold = true }
  unset_alt   = { fg = "${colors.flamingo.hex}", bg = "${colors.surface0.hex}" }

  [indicator]
  parent = { fg = "${colors.base.hex}", bg = "${colors.mauve.hex}" }
  current = { fg = "${colors.base.hex}", bg = "${colors.mauve.hex}" }
  preview = { fg = "${colors.base.hex}", bg = "${colors.mauve.hex}" }

  [status]
  sep_left  = { open = "", close = "" }
  sep_right = { open = "", close = "" }

  progress_label  = { fg = "${colors.mauve.hex}", bold = true }
  progress_normal = { fg = "${colors.green.hex}", bg = "${colors.surface1.hex}" }
  progress_error  = { fg = "${colors.yellow.hex}", bg = "${colors.red.hex}" }

  perm_type  = { fg = "${colors.blue.hex}" }
  perm_read  = { fg = "${colors.yellow.hex}" }
  perm_write = { fg = "${colors.red.hex}" }
  perm_exec  = { fg = "${colors.green.hex}" }
  perm_sep   = { fg = "${colors.overlay1.hex}" }

  [input]
  border   = { fg = "${colors.mauve.hex}" }
  title    = {}
  value    = {}
  selected = { reversed = true }

  [pick]
  border   = { fg = "${colors.mauve.hex}" }
  active   = { fg = "${colors.pink.hex}" }
  inactive = {}

  [confirm]
  border     = { fg = "${colors.mauve.hex}" }
  title      = { fg = "${colors.mauve.hex}" }
  body       = {}
  list       = {}
  btn_yes    = { reversed = true }
  btn_no     = {}

  [cmp]
  border = { fg = "${colors.mauve.hex}" }

  [tasks]
  border  = { fg = "${colors.mauve.hex}" }
  title   = {}
  hovered = { fg = "${colors.pink.hex}", bold = true }

  [which]
  mask            = { bg = "${colors.surface0.hex}" }
  cand            = { fg = "${colors.teal.hex}" }
  rest            = { fg = "${colors.overlay2.hex}" }
  desc            = { fg = "${colors.pink.hex}" }
  separator       = "  "
  separator_style = { fg = "${colors.surface2.hex}" }

  [help]
  on      = { fg = "${colors.teal.hex}" }
  run     = { fg = "${colors.pink.hex}" }
  desc    = { fg = "${colors.overlay2.hex}" }
  hovered = { bg = "${colors.surface2.hex}", bold = true }
  footer  = { fg = "${colors.text.hex}", bg = "${colors.surface1.hex}" }

  [notify]
  title_info  = { fg = "${colors.teal.hex}" }
  title_warn  = { fg = "${colors.yellow.hex}" }
  title_error = { fg = "${colors.red.hex}" }

  [filetype]
  rules = [
    { url = "*/", fg = "${colors.mauve.hex}", bold = true },
    { url = "*", is = "link", fg = "${colors.sky.hex}", italic = true },
    { url = "*", is = "exec", fg = "${colors.green.hex}", bold = true },
    { mime = "image/*", fg = "${colors.peach.hex}" },
    { mime = "video/*", fg = "${colors.red.hex}" },
    { mime = "audio/*", fg = "${colors.yellow.hex}" },
    { url = "*.{zip,tar,tar.gz,rar,7z}", fg = "${colors.maroon.hex}" },
    { url = "*.{pdf,doc,docx,txt,md,rtf}", fg = "${colors.text.hex}" },
    { url = "*.{rs,java,js,ts,jsx,tsx,py,go,nix,lock,lua,toml,json,jsonc,c,h,cpp,hpp}", fg = "${colors.sapphire.hex}" },
  ]

  [spot]
  border = { fg = "${colors.mauve.hex}" }
  title  = { fg = "${colors.mauve.hex}" }
  tbl_cell = { fg = "${colors.mauve.hex}", reversed = true }
  tbl_col = { bold = true }

  [icon]
  files = [
    { name = "dockerfile", text = "󰡨", fg = "${colors.blue.hex}" },
    { name = ".gitignore", text = "", fg = "${colors.peach.hex}" },
    { name = ".gitconfig", text = "", fg = "${colors.peach.hex}" },
    { name = "package.json", text = "", fg = "${colors.red.hex}" },
    { name = "Cargo.toml", text = "", fg = "${colors.peach.hex}" },
    { name = "go.mod", text = "", fg = "${colors.sapphire.hex}" },
    { name = "makefile", text = "", fg = "${colors.overlay1.hex}" },
    { name = "Dockerfile", text = "󰡨", fg = "${colors.blue.hex}" },
    { name = ".dockerignore", text = "󰡨", fg = "${colors.blue.hex}" },
    { name = ".env", text = "", fg = "${colors.yellow.hex}" },
    { name = ".zshrc", text = "", fg = "${colors.green.hex}" },
    { name = ".bashrc", text = "💠", fg = "${colors.green.hex}" },
    { name = "readme.md", text = "󰂺", fg = "${colors.rosewater.hex}" },
    { name = "license.md", text = "", fg = "${colors.yellow.hex}" },
    { name = "license", text = "", fg = "${colors.yellow.hex}" },
      ]

  exts = [

    { name = "rs", text = "", fg = "${colors.peach.hex}" },
    { name = "go", text = "", fg = "${colors.sapphire.hex}" },
    { name = "nix", text = "", fg = "${colors.sapphire.hex}" },
    { name = "lua", text = "", fg = "${colors.sapphire.hex}" },
    { name = "py", text = "", fg = "${colors.yellow.hex}" },
    { name = "toml", text = "", fg = "${colors.surface2.hex}" },
    { name = "java", text = "", fg = "${colors.red.hex}" },
    { name = "md", text = "", fg = "${colors.text.hex}" },

    { name = "js", text = "", fg = "${colors.yellow.hex}" },
    { name = "ts", text = "", fg = "${colors.sapphire.hex}" },
    { name = "jsx", text = "", fg = "${colors.sapphire.hex}" },
    { name = "tsx", text = "", fg = "${colors.surface2.hex}" },

    { name = "json", text = "", fg = "${colors.yellow.hex}" },
    { name = "jsonc", text = "", fg = "${colors.yellow.hex}" },
    
    { name = "c", text = "", fg = "${colors.blue.hex}" },
    { name = "cpp", text = "", fg = "${colors.sapphire.hex}" },
    { name = "h", text = "", fg = "${colors.overlay1.hex}" },
    { name = "hpp", text = "", fg = "${colors.overlay1.hex}" },
    
    { name = "txt", text = "󰈙", fg = "${colors.green.hex}" },
    { name = "pdf", text = "󰈛", fg = "${colors.surface2.hex}" },
    { name = "doc", text = "󰈙", fg = "${colors.surface2.hex}" },
    { name = "docx", text = "󰈙", fg = "${colors.surface2.hex}" },

    { name = "zip", text = "󰗄", fg = "${colors.peach.hex}" },
    { name = "tar", text = "󰗄", fg = "${colors.peach.hex}" },
    { name = "gz", text = "󰗄", fg = "${colors.peach.hex}" },
    { name = "rar", text = "󰗄", fg = "${colors.peach.hex}" },
    { name = "7z", text = "󰗄", fg = "${colors.peach.hex}" },

    { name = "png", text = "", fg = "${colors.overlay1.hex}" },
    { name = "jpg", text = "", fg = "${colors.overlay1.hex}" },
    { name = "jpeg", text = "", fg = "${colors.overlay1.hex}" },
    { name = "gif", text = "", fg = "${colors.overlay1.hex}" },

    { name = "mp3", text = "󰎙", fg = "${colors.sapphire.hex}" },
    { name = "wav", text = "󰎙", fg = "${colors.sapphire.hex}" },
    { name = "flac", text = "󰎙", fg = "${colors.overlay0.hex}" },

    { name = "svg", text = "󰜡", fg = "${colors.peach.hex}" },
    { name = "mp4", text = "󰕧", fg = "${colors.peach.hex}" },
    { name = "mkv", text = "󰕧", fg = "${colors.peach.hex}" },
    { name = "avi", text = "󰕧", fg = "${colors.peach.hex}" },
    { name = "html", text = "󰌝", fg = "${colors.peach.hex}" },

    { name = "css", text = "󰌟", fg = "${colors.blue.hex}" },
    { name = "scss", text = "󰟬", fg = "${colors.red.hex}" },
    { name = "sass", text = "󰟬", fg = "${colors.red.hex}" },

    { name = "yaml", text = "󰈙", fg = "${colors.overlay1.hex}" },
    { name = "yml", text = "󰈙", fg = "${colors.overlay1.hex}" },
    { name = "xml", text = "󰗀", fg = "${colors.peach.hex}" },

    { name = "sh", text = "󰨊", fg = "${colors.surface2.hex}" },
    { name = "bash", text = "󰨊", fg = "${colors.green.hex}" },
    { name = "zsh", text = "󰨊", fg = "${colors.green.hex}" },
    { name = "fish", text = "󰈙", fg = "${colors.surface2.hex}" },

    { name = "rb", text = "󰴭", fg = "${colors.surface0.hex}" },
    { name = "php", text = "󰌟", fg = "${colors.overlay1.hex}" },
    { name = "swift", text = "󰛦", fg = "${colors.peach.hex}" },
    { name = "kt", text = "󱈙", fg = "${colors.overlay0.hex}" },
    { name = "scala", text = "󰘧", fg = "${colors.red.hex}" },
    { name = "vue", text = "󰡄", fg = "${colors.green.hex}" },
    { name = "svelte", text = "󰗄", fg = "${colors.peach.hex}" },
    { name = "astro", text = "󰌎", fg = "${colors.red.hex}" },
    { name = "zig", text = "󰡪", fg = "${colors.peach.hex}" },

    { name = "sql", text = "󰆄", fg = "${colors.rosewater.hex}" },
    { name = "db", text = "󰆄", fg = "${colors.rosewater.hex}" },
    { name = "sqlite", text = "󰆄", fg = "${colors.rosewater.hex}" },

    { name = "r", text = "󰟔", fg = "${colors.overlay0.hex}" },
    { name = "rproj", text = "󰗆", fg = "${colors.green.hex}" },
    { name = "lock", text = "󰌾", fg = "${colors.peach.hex}" },
  ]

  [syntax]
  [theme]
''

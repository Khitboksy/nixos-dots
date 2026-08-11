{ lib, zenith }:

with zenith.lib';

''
  # Yazi Theme - Catppuccin Mocha Mauve (Helios Custom)

  [manager]
  bg = ""

  [manager.file_style]
  bold = false
  italic = false
  dim = false

  [manager.file_style.cursor]
  fg = "${colors.helios.mauve.hex}"
  bold = true
  italic = false

  [manager.file_style.cwd]
  fg = "${colors.helios.mauve.hex}"
  bold = true
  italic = false

  [manager.file_style.marked]
  fg = "${colors.helios.yellow.hex}"
  bold = false
  italic = false

  [mgr]
  cwd = { fg = "${colors.helios.mauve.hex}" }

  find_keyword  = { fg = "${colors.helios.yellow.hex}", italic = true }
  find_position = { fg = "${colors.helios.pink.hex}", bg = "reset", italic = true }

  marker_copied   = { fg = "${colors.helios.green.hex}", bg = "${colors.helios.green.hex}" }
  marker_cut      = { fg = "${colors.helios.red.hex}", bg = "${colors.helios.red.hex}" }
  marker_marked   = { fg = "${colors.helios.teal.hex}", bg = "${colors.helios.teal.hex}" }
  marker_selected = { fg = "${colors.helios.mauve.hex}", bg = "${colors.helios.mauve.hex}" }

  count_copied   = { fg = "${colors.helios.base.hex}", bg = "${colors.helios.green.hex}" }
  count_cut      = { fg = "${colors.helios.base.hex}", bg = "${colors.helios.red.hex}" }
  count_selected = { fg = "${colors.helios.base.hex}", bg = "${colors.helios.mauve.hex}" }

  border_symbol = "│"
  border_style  = { fg = "${colors.helios.overlay1.hex}" }

  syntect_theme = "~/.config/yazi/helios.tmTheme"

  [tabs]
  active   = { fg = "${colors.helios.base.hex}", bg = "${colors.helios.text.hex}", bold = true }
  inactive = { fg = "${colors.helios.text.hex}", bg = "${colors.helios.surface1.hex}" }

  [mode]
  normal_main = { fg = "${colors.helios.base.hex}", bg = "${colors.helios.mauve.hex}", bold = true }
  normal_alt  = { fg = "${colors.helios.mauve.hex}", bg = "${colors.helios.surface0.hex}" }

  select_main = { fg = "${colors.helios.base.hex}", bg = "${colors.helios.green.hex}", bold = true }
  select_alt  = { fg = "${colors.helios.green.hex}", bg = "${colors.helios.surface0.hex}" }

  unset_main  = { fg = "${colors.helios.base.hex}", bg = "${colors.helios.flamingo.hex}", bold = true }
  unset_alt   = { fg = "${colors.helios.flamingo.hex}", bg = "${colors.helios.surface0.hex}" }

  [indicator]
  parent = { fg = "${colors.helios.base.hex}", bg = "${colors.helios.mauve.hex}" }
  current = { fg = "${colors.helios.base.hex}", bg = "${colors.helios.mauve.hex}" }
  preview = { fg = "${colors.helios.base.hex}", bg = "${colors.helios.mauve.hex}" }

  [status]
  sep_left  = { open = "", close = "" }
  sep_right = { open = "", close = "" }

  progress_label  = { fg = "${colors.helios.mauve.hex}", bold = true }
  progress_normal = { fg = "${colors.helios.green.hex}", bg = "${colors.helios.surface1.hex}" }
  progress_error  = { fg = "${colors.helios.yellow.hex}", bg = "${colors.helios.red.hex}" }

  perm_type  = { fg = "${colors.helios.blue.hex}" }
  perm_read  = { fg = "${colors.helios.yellow.hex}" }
  perm_write = { fg = "${colors.helios.red.hex}" }
  perm_exec  = { fg = "${colors.helios.green.hex}" }
  perm_sep   = { fg = "${colors.helios.overlay1.hex}" }

  [input]
  border   = { fg = "${colors.helios.mauve.hex}" }
  title    = {}
  value    = {}
  selected = { reversed = true }

  [pick]
  border   = { fg = "${colors.helios.mauve.hex}" }
  active   = { fg = "${colors.helios.pink.hex}" }
  inactive = {}

  [confirm]
  border     = { fg = "${colors.helios.mauve.hex}" }
  title      = { fg = "${colors.helios.mauve.hex}" }
  body       = {}
  list       = {}
  btn_yes    = { reversed = true }
  btn_no     = {}

  [cmp]
  border = { fg = "${colors.helios.mauve.hex}" }

  [tasks]
  border  = { fg = "${colors.helios.mauve.hex}" }
  title   = {}
  hovered = { fg = "${colors.helios.pink.hex}", bold = true }

  [which]
  mask            = { bg = "${colors.helios.surface0.hex}" }
  cand            = { fg = "${colors.helios.teal.hex}" }
  rest            = { fg = "${colors.helios.overlay2.hex}" }
  desc            = { fg = "${colors.helios.pink.hex}" }
  separator       = "  "
  separator_style = { fg = "${colors.helios.surface2.hex}" }

  [help]
  on      = { fg = "${colors.helios.teal.hex}" }
  run     = { fg = "${colors.helios.pink.hex}" }
  desc    = { fg = "${colors.helios.overlay2.hex}" }
  hovered = { bg = "${colors.helios.surface2.hex}", bold = true }
  footer  = { fg = "${colors.helios.text.hex}", bg = "${colors.helios.surface1.hex}" }

  [notify]
  title_info  = { fg = "${colors.helios.teal.hex}" }
  title_warn  = { fg = "${colors.helios.yellow.hex}" }
  title_error = { fg = "${colors.helios.red.hex}" }

  [filetype]
  rules = [
    { url = "*/", fg = "${colors.helios.mauve.hex}", bold = true },
    { url = "*", is = "link", fg = "${colors.helios.sky.hex}", italic = true },
    { url = "*", is = "exec", fg = "${colors.helios.green.hex}", bold = true },
    { mime = "image/*", fg = "${colors.helios.peach.hex}" },
    { mime = "video/*", fg = "${colors.helios.red.hex}" },
    { mime = "audio/*", fg = "${colors.helios.yellow.hex}" },
    { url = "*.{zip,tar,tar.gz,rar,7z}", fg = "${colors.helios.maroon.hex}" },
    { url = "*.{pdf,doc,docx,txt,md,rtf}", fg = "${colors.helios.text.hex}" },
    { url = "*.{rs,java,js,ts,jsx,tsx,py,go,nix,lock,lua,toml,json,jsonc,c,h,cpp,hpp}", fg = "${colors.helios.sapphire.hex}" },
  ]

  [spot]
  border = { fg = "${colors.helios.mauve.hex}" }
  title  = { fg = "${colors.helios.mauve.hex}" }
  tbl_cell = { fg = "${colors.helios.mauve.hex}", reversed = true }
  tbl_col = { bold = true }

  [icon]
  files = [
    { name = "dockerfile", text = "󰡨", fg = "${colors.helios.blue.hex}" },
    { name = ".gitignore", text = "", fg = "${colors.helios.peach.hex}" },
    { name = ".gitconfig", text = "", fg = "${colors.helios.peach.hex}" },
    { name = "package.json", text = "", fg = "${colors.helios.red.hex}" },
    { name = "Cargo.toml", text = "", fg = "${colors.helios.peach.hex}" },
    { name = "go.mod", text = "", fg = "${colors.helios.sapphire.hex}" },
    { name = "makefile", text = "", fg = "${colors.helios.overlay1.hex}" },
    { name = "Dockerfile", text = "󰡨", fg = "${colors.helios.blue.hex}" },
    { name = ".dockerignore", text = "󰡨", fg = "${colors.helios.blue.hex}" },
    { name = ".env", text = "", fg = "${colors.helios.yellow.hex}" },
    { name = ".zshrc", text = "", fg = "${colors.helios.green.hex}" },
    { name = ".bashrc", text = "💠", fg = "${colors.helios.green.hex}" },
    { name = "readme.md", text = "󰂺", fg = "${colors.helios.rosewater.hex}" },
    { name = "license.md", text = "", fg = "${colors.helios.yellow.hex}" },
    { name = "license", text = "", fg = "${colors.helios.yellow.hex}" },
      ]

  exts = [

    { name = "rs", text = "", fg = "${colors.helios.peach.hex}" },
    { name = "go", text = "", fg = "${colors.helios.sapphire.hex}" },
    { name = "nix", text = "", fg = "${colors.helios.sapphire.hex}" },
    { name = "lua", text = "", fg = "${colors.helios.sapphire.hex}" },
    { name = "py", text = "", fg = "${colors.helios.yellow.hex}" },
    { name = "toml", text = "", fg = "${colors.helios.surface2.hex}" },
    { name = "java", text = "", fg = "${colors.helios.red.hex}" },
    { name = "md", text = "", fg = "${colors.helios.text.hex}" },

    { name = "js", text = "", fg = "${colors.helios.yellow.hex}" },
    { name = "ts", text = "", fg = "${colors.helios.sapphire.hex}" },
    { name = "jsx", text = "", fg = "${colors.helios.sapphire.hex}" },
    { name = "tsx", text = "", fg = "${colors.helios.surface2.hex}" },

    { name = "json", text = "", fg = "${colors.helios.yellow.hex}" },
    { name = "jsonc", text = "", fg = "${colors.helios.yellow.hex}" },
    
    { name = "c", text = "", fg = "${colors.helios.blue.hex}" },
    { name = "cpp", text = "", fg = "${colors.helios.sapphire.hex}" },
    { name = "h", text = "", fg = "${colors.helios.overlay1.hex}" },
    { name = "hpp", text = "", fg = "${colors.helios.overlay1.hex}" },
    
    { name = "txt", text = "󰈙", fg = "${colors.helios.green.hex}" },
    { name = "pdf", text = "󰈛", fg = "${colors.helios.surface2.hex}" },
    { name = "doc", text = "󰈙", fg = "${colors.helios.surface2.hex}" },
    { name = "docx", text = "󰈙", fg = "${colors.helios.surface2.hex}" },

    { name = "zip", text = "󰗄", fg = "${colors.helios.peach.hex}" },
    { name = "tar", text = "󰗄", fg = "${colors.helios.peach.hex}" },
    { name = "gz", text = "󰗄", fg = "${colors.helios.peach.hex}" },
    { name = "rar", text = "󰗄", fg = "${colors.helios.peach.hex}" },
    { name = "7z", text = "󰗄", fg = "${colors.helios.peach.hex}" },

    { name = "png", text = "", fg = "${colors.helios.overlay1.hex}" },
    { name = "jpg", text = "", fg = "${colors.helios.overlay1.hex}" },
    { name = "jpeg", text = "", fg = "${colors.helios.overlay1.hex}" },
    { name = "gif", text = "", fg = "${colors.helios.overlay1.hex}" },

    { name = "mp3", text = "󰎙", fg = "${colors.helios.sapphire.hex}" },
    { name = "wav", text = "󰎙", fg = "${colors.helios.sapphire.hex}" },
    { name = "flac", text = "󰎙", fg = "${colors.helios.overlay0.hex}" },

    { name = "svg", text = "󰜡", fg = "${colors.helios.peach.hex}" },
    { name = "mp4", text = "󰕧", fg = "${colors.helios.peach.hex}" },
    { name = "mkv", text = "󰕧", fg = "${colors.helios.peach.hex}" },
    { name = "avi", text = "󰕧", fg = "${colors.helios.peach.hex}" },
    { name = "html", text = "󰌝", fg = "${colors.helios.peach.hex}" },

    { name = "css", text = "󰌟", fg = "${colors.helios.blue.hex}" },
    { name = "scss", text = "󰟬", fg = "${colors.helios.red.hex}" },
    { name = "sass", text = "󰟬", fg = "${colors.helios.red.hex}" },

    { name = "yaml", text = "󰈙", fg = "${colors.helios.overlay1.hex}" },
    { name = "yml", text = "󰈙", fg = "${colors.helios.overlay1.hex}" },
    { name = "xml", text = "󰗀", fg = "${colors.helios.peach.hex}" },

    { name = "sh", text = "󰨊", fg = "${colors.helios.surface2.hex}" },
    { name = "bash", text = "󰨊", fg = "${colors.helios.green.hex}" },
    { name = "zsh", text = "󰨊", fg = "${colors.helios.green.hex}" },
    { name = "fish", text = "󰈙", fg = "${colors.helios.surface2.hex}" },

    { name = "rb", text = "󰴭", fg = "${colors.helios.surface0.hex}" },
    { name = "php", text = "󰌟", fg = "${colors.helios.overlay1.hex}" },
    { name = "swift", text = "󰛦", fg = "${colors.helios.peach.hex}" },
    { name = "kt", text = "󱈙", fg = "${colors.helios.overlay0.hex}" },
    { name = "scala", text = "󰘧", fg = "${colors.helios.red.hex}" },
    { name = "vue", text = "󰡄", fg = "${colors.helios.green.hex}" },
    { name = "svelte", text = "󰗄", fg = "${colors.helios.peach.hex}" },
    { name = "astro", text = "󰌎", fg = "${colors.helios.red.hex}" },
    { name = "zig", text = "󰡪", fg = "${colors.helios.peach.hex}" },

    { name = "sql", text = "󰆄", fg = "${colors.helios.rosewater.hex}" },
    { name = "db", text = "󰆄", fg = "${colors.helios.rosewater.hex}" },
    { name = "sqlite", text = "󰆄", fg = "${colors.helios.rosewater.hex}" },

    { name = "r", text = "󰟔", fg = "${colors.helios.overlay0.hex}" },
    { name = "rproj", text = "󰗆", fg = "${colors.helios.green.hex}" },
    { name = "lock", text = "󰌾", fg = "${colors.helios.peach.hex}" },
  ]

  [syntax]
  [theme]
''

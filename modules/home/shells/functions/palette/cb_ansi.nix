{
  # ── Cursor / line clearing ──
  _cb_ansi_erase_line = ''
    printf "\e[2K"
  '';

  _cb_ansi_cr = ''
    printf "\r"
  '';

  _cb_ansi_cursor_move_up = ''
    set -q n; or set n 1
    printf "\e[$nA"
  '';

  _cb_ansi_cursor_move_start_up = ''
    set -q n; or set n 1
    printf "\e[$nF"
  '';

  # ── Confirmation message (cursor-aware) ──
  _cb_confirm_msg = ''
    set -l msg $argv[1]
    _cb_ansi_erase_line
    _cb_ansi_cr
    _cb_ansi_cursor_move_up
    _cb_ansi_erase_line
    _cb_ansi_cr
    set_color e49641
    echo "$msg"
    set_color normal
    _cb_ansi_cursor_move_start_up 2
    _cb_ansi_erase_line
    _cb_ansi_cr
    _cb_ansi_cursor_move_start_up
    _cb_ansi_erase_line
    _cb_ansi_cr
  '';
}

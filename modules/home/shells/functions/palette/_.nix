{ pkgs, lib, ... }:
let
  # Tool paths — inlined into fish function bodies at build time.
  cb_pastel = "${lib.getExe pkgs.pastel}";
  cb_fzf = "${lib.getExe pkgs.fzf}";
  cb_jq = "${lib.getExe pkgs.jq}";
  cb_wl_copy = "${lib.getExe' pkgs.wl-clipboard-rs "wl-copy"}";
  cb_color_file = "$HOME/builds/lib/theme/colors/palette.json";

  # Inline script for the preview/command pane.
  _cb_inline_mod = import ./cb_inline.nix { inherit pkgs lib; };
  inherit (_cb_inline_mod) cb_inline_script_file;

in
{
  # ── Preview: render a color swatch ──
  _cb_preview = ''
    set -l hex $argv[1]
    set -l paired_hex $argv[2]
    set -l _cb_pastel "${cb_pastel}"
    set -l _cb_jq "${cb_jq}"
    set -l _cb_color_file "${cb_color_file}"
    $_cb_pastel color $hex 2>/dev/null; or true
    echo -n "  "
    set_color $hex
    echo "extended example text"
    set_color normal
    echo -n "  "
    set_color ($_cb_pastel textcolor $hex | $_cb_pastel format hex)
    set_color -b $hex
    echo "extended example text"
    set_color normal
    if test -n "$paired_hex"
      set -l pname ($_cb_jq -r --arg h "$paired_hex" '.[] | select(.[1]==$h) | .[0]' $_cb_color_file)
      if test -z "$pname"
        set pname "custom"
      end
      echo -n "  "
      set_color $hex
      set_color -b $paired_hex
      echo "this text on $pname background"
      set_color normal
      echo -n "  "
      set_color $paired_hex
      set_color -b $hex
      echo "$pname text on this background"
      set_color normal
    end
  '';

  # ── Preview with optional message (for confirmations) ──
  _cb_redraw = ''
    set -l hex $argv[1]
    set -l paired $argv[2]
    set -l msg $argv[3]
    clear
    _cb_preview $hex $paired
    echo
    if test -n "$msg"
      set_color e49641
      echo $msg
      set_color normal
      echo
    end
  '';

  # ── Color grid: display all named colors ──
  _cb_show_all = ''
    set -l _cb_jq "${cb_jq}"
    set -l _cb_pastel "${cb_pastel}"
    set -l _cb_color_file "${cb_color_file}"
    $_cb_jq -r '.[] | "\(.[0])\t\(.[1])"' $_cb_color_file | while read -l name hex
      set_color $hex
      printf "%-22s" "$name"
      set_color normal
      printf "  "
      set_color -b $hex
      set_color ($_cb_pastel textcolor $hex | $_cb_pastel format hex)
      printf "%-22s" "$name"
      set_color normal
      echo
    end
  '';

  # ── Tmux three-pane layout ──
  palette = ''
    # If not in tmux, spawn a dedicated tmux session
    if not set -q TMUX
      set -l pal_src (status filename 2>/dev/null)
      set -l pal_session "palette-$PPID"
      if test -n "$pal_src" -a -f "$pal_src"
        tmux new-session -d -s "$pal_session" "source $pal_src; and palette"
      else
        tmux new-session -d -s "$pal_session" "palette"
      end
      tmux attach-session -t "$pal_session"
      while tmux has-session -t "$pal_session" 2>/dev/null
        sleep 0.5
      end
      return
    end

    set -l _cb_pastel "${cb_pastel}"
    set -l _cb_jq "${cb_jq}"
    set -l _cb_fzf "${cb_fzf}"
    set -l _cb_wl_copy "${cb_wl_copy}"
    set -l _cb_color_file "${cb_color_file}"
    set -l current_pane (tmux display-message -p '#{pane_id}')

    # ── Clean up any leftover files from previous crashed sessions ──
    # Use ls + string match instead of shell globs — fish 4.x treats unmatched
    # globs as fatal errors (e.g. /tmp/palette-restart.* won't exist because
    # restart_file uses mktemp -u — it's created on demand by the inline script).
    for f in (ls /tmp/ 2>/dev/null | string match 'palette-*')
        rm -f "/tmp/$f"
    end

    # ── Temp files for IPC ──
    set -l sel_file      (mktemp /tmp/palette-sel.XXXXXX)
    set -l cmt_file      (mktemp /tmp/palette-commit.XXXXXX)
    set -l res_file      (mktemp -u /tmp/palette-result.XXXXXX)
    set -l chld_id_file  (mktemp /tmp/palette-child-id.XXXXXX)
    set -l prev_id_file  (mktemp /tmp/palette-preview-id.XXXXXX)
    set -l names_file    (mktemp /tmp/palette-names.XXXXXX)
    set -l restart_file  (mktemp -u /tmp/palette-restart.XXXXXX)

    # ── Write initial colour names to names_file ──
    printf '%s\n' '--- Enter a new color ---' > $names_file
    $_cb_jq -r '.[] | .[0]' $_cb_color_file >> $names_file

    # ── Config file: IPC paths for the inline script ──
    set -l cfg_file (mktemp /tmp/palette-cfg.XXXXXX)
    printf '%s\n' "$sel_file"     > "$cfg_file"
    printf '%s\n' "$cmt_file"     >> "$cfg_file"
    printf '%s\n' "$chld_id_file" >> "$cfg_file"
    printf '%s\n' "$prev_id_file" >> "$cfg_file"
    printf '%s\n' "$names_file"   >> "$cfg_file"  # line 5
    printf '%s\n' "$restart_file" >> "$cfg_file"  # line 6

    # ── Copy inline script from Nix store ──
    set -l inline_script (mktemp /tmp/palette-inline.XXXXXX)
    cp "${cb_inline_script_file}" "$inline_script"

    # ── Create three-pane layout ──
    #   current_pane (top-left):  color grid
    #   child_pane (bottom 30%):  fzf color picker
    #   preview_pane (top-right): preview/command/edit

    set -l picker_cmd "cat $names_file | $_cb_fzf --height=100% --no-sort -e --no-mouse --border --cycle --layout=reverse --bind='focus:execute-silent(echo {} > $sel_file.tmp; and mv $sel_file.tmp $sel_file)' --bind='enter:execute-silent(echo {} > $cmt_file.tmp; and mv $cmt_file.tmp $cmt_file; and tmux select-pane -t (cat $prev_id_file))' --bind='f5:reload(cat $names_file)' > $res_file.tmp; and mv $res_file.tmp $res_file"

    set -l child_pane (tmux split-window -v -p 30 -P -F '#{pane_id}' -t $current_pane "$picker_cmd")
    echo $child_pane > $chld_id_file

    set -l preview_pane (tmux split-window -h -p 59 -P -F '#{pane_id}' -t $current_pane "env PALETTE_CFG=$cfg_file fish $inline_script")
    echo $preview_pane > $prev_id_file

    tmux select-pane -t $child_pane
    _cb_show_all
    set_color normal
    echo

    # ── Wait for fzf to finish ──
    while true
      if test -f $res_file
        break
      end

      # ── Refresh grid when inline script signals a save ──
      if test -f $restart_file
        rm -f $restart_file
        clear
        _cb_show_all
        set_color normal
        echo
        continue
      end

      if not tmux list-panes -a -F '#{pane_id}' 2>/dev/null | grep -qxF "$child_pane"
        break
      end

      sleep 0.2
    end

    # ── Cleanup ──
    tmux kill-pane -t $preview_pane 2>/dev/null; or true
    rm -f $sel_file $sel_file.tmp $cmt_file $cmt_file.tmp $res_file $res_file.tmp $chld_id_file $prev_id_file $names_file $restart_file $cfg_file $inline_script 2>/dev/null
  '';
}
// (import ./cb_ansi.nix)
// (import ./cb_colors.nix {
  inherit
    cb_pastel
    cb_jq
    cb_color_file
    cb_fzf
    ;
})

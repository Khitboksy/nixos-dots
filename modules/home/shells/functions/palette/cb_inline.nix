{ pkgs, lib, ... }: let
  pcb_pastel     = "${lib.getExe pkgs.pastel}";
  pcb_jq         = "${lib.getExe pkgs.jq}";
  pcb_fzf        = "${lib.getExe pkgs.fzf}";
  pcb_wl_copy    = "${lib.getExe' pkgs.wl-clipboard-rs "wl-copy"}";
  pcb_color_file = "$HOME/builds/lib/theme/colors/palette.json";
in rec {
  # Standalone script for the top-right preview/command/edit pane.
  cb_inline_script_file = pkgs.writeScript "palette-inline.fish" _cb_inline_script;

  _cb_inline_script = ''
    #!/usr/bin/env fish

    # ── Global paths ──
    set -g pcb_pastel     "${pcb_pastel}"
    set -g pcb_jq         "${pcb_jq}"
    set -g pcb_fzf        "${pcb_fzf}"
    set -g pcb_wl_copy    "${pcb_wl_copy}"
    set -g pcb_color_file "${pcb_color_file}"

    # ── IPC paths (read from config file written by palette) ──
    set -g pcb_cfg $PALETTE_CFG
    set -g sel_file       (sed -n '1p' $pcb_cfg)
    set -g cmt_file       (sed -n '2p' $pcb_cfg)
    set -g chld_id_file   (sed -n '3p' $pcb_cfg)
    set -g prev_id_file   (sed -n '4p' $pcb_cfg)
    set -g names_file     (sed -n '5p' $pcb_cfg)
    set -g restart_file   (sed -n '6p' $pcb_cfg)

    # ── Child pane ID ──
    set -l chld_pane (cat $chld_id_file 2>/dev/null)
    if test -z "$chld_pane"
      for i in (seq 1 50)
        sleep 0.1
        set chld_pane (cat $chld_id_file 2>/dev/null)
        if test -n "$chld_pane"; break; end
      end
    end

    # ── Adjustment dispatcher (operates on globals $current / $paired) ──
    function _cb_adjust -a key
      switch $key
        case r; set -g current (_cb_adjust_channel $current r 1)
        case R; set -g current (_cb_adjust_channel $current r -1)
        case g; set -g current (_cb_adjust_channel $current g 1)
        case G; set -g current (_cb_adjust_channel $current g -1)
        case b; set -g current (_cb_adjust_channel $current b 1)
        case B; set -g current (_cb_adjust_channel $current b -1)
        case j; set -g current ($pcb_pastel rotate 1 $current | $pcb_pastel format hex)
        case J; set -g current ($pcb_pastel rotate -- -1 $current | $pcb_pastel format hex)
        case l; set -g current ($pcb_pastel lighten 0.01 $current | $pcb_pastel format hex)
        case L; set -g current ($pcb_pastel darken 0.01 $current | $pcb_pastel format hex)
        case k; set -g current ($pcb_pastel saturate 0.01 $current | $pcb_pastel format hex)
        case K; set -g current ($pcb_pastel desaturate 0.01 $current | $pcb_pastel format hex)
        case '*'; return 1
      end
      _cb_redraw $current $paired ""
      return 0
    end

    # ── State ──
    set -g last_sel ""
    set -g mode preview
    set -g current ""
    set -g paired ""
    set -g edit_base_name ""
    set -g _cb_save_pending ""

    while true
      # ── Handle pending save prompt (outside menu loop to avoid _cb_get_key→read conflict) ──
      if test -n "$_cb_save_pending"
        and test "$_cb_save_pending" != ""
        printf "\e[4A\e[J"
        set -l save_name ""
        if test -n "$edit_base_name"
          and test "$edit_base_name" != "custom"
          echo -n "Overwrite \"$edit_base_name\"? [y/N]: "
          set -l answer (head -n 1)
          set answer (string trim -- $answer)
          switch $answer
            case y Y yes YES
              set save_name "$edit_base_name"
            case '*'
              if test -n "$answer"
                set save_name "$answer"
              else
                set save_name ""
              end
          end
        else
          echo -n "Name: "
          set save_name (head -n 1)
          set save_name (string trim -- $save_name)
        end

        if test -n "$save_name"
          set -l clean ($pcb_pastel format hex $current)
          if test -z "$clean"
            set -g _cb_status "Error: pastel failed"
            set -g _cb_save_pending ""
            continue
          end
          $pcb_jq --arg n "$save_name" --arg h "$clean" \
            'if any(.[]; .[0] == $n) then map(if .[0] == $n then [$n, $h] else . end) else . + [[$n, $h]] end' \
            $pcb_color_file \
          | $pcb_jq -r '24 as $w | [.[] | "  [\"\(.[0])\", \(" " * ([$w - (.[0] | length), 0] | max))\"\(.[1])\"]"] as $lines | "[\n" + ($lines | join(",\n")) + "\n]"' \
            > $pcb_color_file.tmp
          and mv $pcb_color_file.tmp $pcb_color_file
          and begin
            set -g _cb_status "$save_name written"
            printf '%s\n' '--- Enter a new color ---' > $names_file
            $pcb_jq -r '.[] | .[0]' $pcb_color_file >> $names_file
            echo restart > $restart_file
            tmux send-keys -t $chld_pane F5
          end
          or begin
            rm -f $pcb_color_file.tmp 2>/dev/null
            set -g _cb_status "Error: failed to save \"$save_name\""
          end
        else
          set -g _cb_status ""
        end

        set -g _cb_save_pending ""
        continue
      end
      if test "$mode" = preview
        # ── Focus preview ──
        set -l sel (cat $sel_file 2>/dev/null)
        if test -n "$sel"
          and test "$sel" != "$last_sel"
          and test "$sel" != '--- Enter a new color ---'
          clear
          set -l hex ($pcb_jq -r --arg k "$sel" '.[] | select(.[0]==$k) | .[1]' $pcb_color_file 2>/dev/null)
          if test -n "$hex"
            _cb_preview $hex ""
            echo
          end
          set last_sel "$sel"
        end

        # ── Commit (Enter in fzf) ──
        set -l cmt (cat $cmt_file 2>/dev/null)
        if test -n "$cmt"
          and test "$cmt" != '--- Enter a new color ---'
          set current ($pcb_jq -r --arg k "$cmt" '.[] | select(.[0]==$k) | .[1]' $pcb_color_file)
          set paired ""
          set mode command
        else if test "$cmt" = '--- Enter a new color ---'
          set current ($pcb_pastel random -n 1 | $pcb_pastel format hex)
          set paired ""
          set mode command
        end
      end

      if test "$mode" = command
        # ── Command mode ──
        clear
        _cb_preview $current $paired
        echo

        while true
          echo "neo[w]im  [e]dit  [i]nput  f[z]f"
          echo "[p]air   [P]air-clear"
          echo "[s]ex   [c]rgb   [d]hsl   [f]lip"

          set -l key (_cb_get_key)
          switch $key
            case w
              $EDITOR $pcb_color_file
              continue

            case e
              set edit_base_name ($pcb_jq -r --arg h "$current" '.[] | select(.[1]==$h) | .[0]' $pcb_color_file 2>/dev/null)
              if test -z "$edit_base_name"; set edit_base_name "custom"; end
              set mode edit
              break

            case i
              read -l hex -P "hex: "
              if test -z "$hex"; continue; end
              set -l hex_pattern "^#[0-9a-fA-F]{6}\$"
              if not string match -r $hex_pattern $hex
                _cb_redraw $current $paired "invalid hex"
                continue
              end
              set current $hex
              set paired ""
              set edit_base_name "custom"
              set mode edit
              break

            case z
              echo -n > $cmt_file
              tmux select-pane -t $chld_pane
              set mode preview
              set last_sel ""
              break

            case s
              echo $current | $pcb_wl_copy -n
              _cb_redraw $current $paired "$current copied"
              continue

            case c
              set -l rgb ($pcb_pastel format rgb $current)
              echo $rgb | $pcb_wl_copy -n
              _cb_redraw $current $paired "$rgb copied"
              continue

            case d
              set -l hsl ($pcb_pastel format hsl $current)
              echo $hsl | $pcb_wl_copy -n
              _cb_redraw $current $paired "$hsl copied"
              continue

            case f
              set current ($pcb_pastel complement $current | $pcb_pastel format hex)
              _cb_redraw $current $paired "flip $current"
              continue

            case p
              set -l pc (_cb_pick_pair_color)
              if test -n "$pc"
                set paired $pc
                _cb_redraw $current $paired "paired: $pc"
              else
                _cb_redraw $current $paired ""
              end
              continue

            case P
              set paired ""
              _cb_redraw $current $paired "pair cleared"
              continue
          end
          break
        end
      end

      if test "$mode" = edit
        # ── Edit mode ──
        clear
        _cb_preview $current $paired
        echo

        if test -n "$edit_base_name"
          set_color e49641
          echo "editing: $edit_base_name"
          set_color normal
        end

        if set -q _cb_status
          and test -n "$_cb_status"
          set_color e49641
          echo $_cb_status
          set_color normal
          set -e _cb_status
        end
        echo

        while true
          echo "[p]air   [P]air-clear"
          echo "[w]rite (save)  [e]xit edit  f[z]f"
          echo "+[r]ed -[R]ed   +[g]reen -[G]green   +[b]lue -[B]lue"
          echo "+[j]ue -[J]ue   +[l]ight -[L]light   +sa[k]urate -sa[K]urate"

          set -l key (_cb_get_key)
          switch $key
            case w
              set -g _cb_save_pending "yes"
              break

            case e
              set mode command
              break

            case z
              echo -n > $cmt_file
              tmux select-pane -t $chld_pane
              set mode preview
              set last_sel ""
              break

            case p
              set -l pc (_cb_pick_pair_color)
              if test -n "$pc"
                set paired $pc
                _cb_redraw $current $paired "paired: $pc"
              else
                _cb_redraw $current $paired ""
              end
              continue

            case P
              set paired ""
              _cb_redraw $current $paired "pair cleared"
              continue

            case r R g G b B j J l L k K
              _cb_adjust $key
              continue
          end
          break
        end
      end

      sleep 0.1
    end
  '';
}

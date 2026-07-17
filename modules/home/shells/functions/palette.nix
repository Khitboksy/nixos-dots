# Depends on: jq, pastel, fzf, wl-clipboard (all in nixpkgs)
''
  set -g _cb_color_file $HOME/builds/lib/theme/colors/palette.json

  # ── helpers ──────────────────────────────────────────────

  function _cb_get_key
      set -l state (stty -g 2>/dev/null)
      stty raw -echo 2>/dev/null
      set -l key (dd bs=1 count=1 2>/dev/null)
      stty "$state" 2>/dev/null
      echo "$key"
  end

  function _cb_adjust_channel -a hex channel delta
      set -l parts (string match -r 'rgb\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)' (pastel format rgb $hex))
      if test (count $parts) -ne 4
          return 1
      end
      set -l r $parts[2]
      set -l g $parts[3]
      set -l b $parts[4]
      switch $channel
          case r; set r (math $r + $delta)
          case g; set g (math $g + $delta)
          case b; set b (math $b + $delta)
      end
      # Clamp to 0-255
      if test $r -gt 255; set r 255; else if test $r -lt 0; set r 0; end
      if test $g -gt 255; set g 255; else if test $g -lt 0; set g 0; end
      if test $b -gt 255; set b 255; else if test $b -lt 0; set b 0; end
      pastel color "rgb($r, $g, $b)" | pastel format hex
  end

  function _cb_write_color -a hex name
      set -l clean (pastel format hex $hex)
      jq --arg n "$name" --arg h "$clean" '.[$n] = $h' $_cb_color_file > $_cb_color_file.tmp
      and mv $_cb_color_file.tmp $_cb_color_file
      or begin; rm -f $_cb_color_file.tmp; end
  end

  # ── display ──────────────────────────────────────────────

  function _cb_show_all
      jq -r 'to_entries[] | "\(.key)\t\(.value)"' $_cb_color_file | while read -l name hex
          set_color $hex
          printf "%-22s" "$name"
          set_color normal
          echo -n "  "
          set_color -b $hex
          set_color (pastel textcolor $hex | pastel format hex)
          echo "$name"
          set_color normal
      end
  end

  function _cb_preview -a hex paired_hex
      # small swatch block
      pastel color $hex 2>/dev/null; or true
      # foreground sample
      set_color $hex
      echo "  extended example text"
      set_color normal
      # background sample (auto-contrast)
      set_color (pastel textcolor $hex | pastel format hex)
      set_color -b $hex
      echo "  auto-contrast text on this background"
      set_color normal
      # paired preview (if set)
      if test -n "$paired_hex"
          set -l pname (jq -r --arg h "$paired_hex" 'to_entries[] | select(.value==$h) | .key' $_cb_color_file)
          if test -z "$pname"; set pname "custom"; end
          set_color $paired_hex
          set_color -b $hex
          echo "  $pname text on this background"
          set_color normal
      end
  end

  # ── pickers ──────────────────────────────────────────────

  function _cb_pick_color
      set -l list (jq -r 'to_entries[] | "\(.key)  │  \(.value)"' $_cb_color_file)
      set -l picked (printf "%s\n%s" "─── Enter a new color ───" "$list" \
          | fzf --height 50% -e --with-nth=1 --border --cycle)
      switch "$picked"
          case "─── Enter a new color ───"
              echo -n "hex (empty = random): "
              read -l hex
              if test -z "$hex"
                  pastel random | pastel format hex
              else
                  pastel format hex $hex
              end
          case '*'
              string split ' │ ' -- $picked | tail -1 | string trim
      end
  end

  function _cb_pick_name
      set -l picked (jq -r 'keys[]' $_cb_color_file \
          | fzf --height 40% --print-query --prompt="name > " --border --cycle)
      if test -z "$picked"; return 1; end
      set -l lines (string split \n -- $picked)
      set -l query $lines[1]
      set -l selection $lines[2..-1]
      if test -n "$selection"; echo "$selection"
      else if test -n "$query"; echo "$query"
      else; return 1; end
  end

  function _cb_pick_pair_color
      jq -r 'to_entries[] | "\(.key)  │  \(.value)"' $_cb_color_file \
          | fzf --height 50% -e --with-nth=1 --border --cycle \
          | string split ' │ ' -- | tail -1 | string trim
  end

  # ── main entry point ─────────────────────────────────────

  function palette
      while true
          echo
          echo "=== palette ==============================="
          _cb_show_all
          echo

          set -l color (_cb_pick_color)
          if test -z "$color"; continue; end

          set -l current (pastel format hex $color)
          set -l paired ""

          while true
              echo
              _cb_preview $current $paired
              echo
              echo -n "[w]rite [i]nput [e]dit [p]air [P]air-clear "
              echo -n "[s]ex [c]rgb [d]hsl [f]lip "
              echo -n "[r]ed [R]ed [g]reen [G]reen [b]lue [B]lue "
              echo -n "[j]ue [J]ue [l]ight [L]ight sa[k]urate sa[K]urate"
              echo

              set -l key (_cb_get_key)
              echo

              switch "$key"
                  case w
                      set -l name (_cb_pick_name)
                      if test -n "$name"
                          _cb_write_color $current $name
                          echo "-> saved '$name'"
                      end

                  case i; break
                  case e; $EDITOR $_cb_color_file

                  case s; echo $current | wl-copy -n; echo "-> hex copied"
                  case c; pastel format rgb $current | wl-copy -n; echo "-> rgb copied"
                  case d; pastel format hsl $current | wl-copy -n; echo "-> hsl copied"

                  case f; set current (pastel complement $current | pastel format hex)

                  case p
                      set -l pc (_cb_pick_pair_color)
                      if test -n "$pc"; set paired $pc; end
                  case P; set paired ""

                  case r; set current (_cb_adjust_channel $current r 1)
                  case R; set current (_cb_adjust_channel $current r -1)
                  case g; set current (_cb_adjust_channel $current g 1)
                  case G; set current (_cb_adjust_channel $current g -1)
                  case b; set current (_cb_adjust_channel $current b 1)
                  case B; set current (_cb_adjust_channel $current b -1)

                  case j; set current (pastel rotate 1 $current | pastel format hex)
                  case J; set current (pastel rotate -- -1 $current | pastel format hex)

                  case l; set current (pastel lighten 0.01 $current | pastel format hex)
                  case L; set current (pastel darken 0.01 $current | pastel format hex)

                  case k; set current (pastel saturate 0.01 $current | pastel format hex)
                  case K; set current (pastel desaturate 0.01 $current | pastel format hex)
              end
          end
      end
  end
''

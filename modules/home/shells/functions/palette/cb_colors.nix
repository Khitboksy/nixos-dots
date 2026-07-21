{
  cb_pastel,
  cb_jq,
  cb_fzf,
  cb_color_file,
  ...
}:
{
  # ── Single keypress read ──
  _cb_get_key = ''
    set -l state (stty -g 2>/dev/null)
    stty raw -echo 2>/dev/null
    set -l key (dd bs=1 count=1 2>/dev/null)
    stty "$state" 2>/dev/null
    echo "$key"
  '';

  # ── RGB channel adjust ──
  _cb_adjust_channel = ''
    set -l hex $argv[1]
    set -l channel $argv[2]
    set -l delta $argv[3]
    set -l _cb_pastel "${cb_pastel}"
    set -l parts (string match -r 'rgb\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)' ($_cb_pastel format rgb $hex))
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
    if test $r -gt 255; set r 255; else if test $r -lt 0; set r 0; end
    if test $g -gt 255; set g 255; else if test $g -lt 0; set g 0; end
    if test $b -gt 255; set b 255; else if test $b -lt 0; set b 0; end
    $_cb_pastel color "rgb($r, $g, $b)" | $_cb_pastel format hex
  '';

  # ── Save color to palette file ──
  _cb_save_color = ''
    set -l hex $argv[1]
    set -l name $argv[2]
    set -l _cb_pastel "${cb_pastel}"
    set -l _cb_jq "${cb_jq}"
    set -l _cb_color_file "${cb_color_file}"
    set -l clean ($_cb_pastel format hex $hex)
    $_cb_jq --arg n "$name" --arg h "$clean" \
      'map(if .[0] == $n then [$n, $h] else . end) as $updated | if $updated == . then $updated + [[$n, $h]] else $updated end' \
      $_cb_color_file \
    | $_cb_jq -r '24 as $w | [.[] | "  [\"\(.[0])\", \(" " * ([$w - (.[0] | length), 0] | max))\"\(.[1])\"]"] as $lines | "[\n" + ($lines | join(",\n")) + "\n]"' \
      > $_cb_color_file.tmp
    and mv $_cb_color_file.tmp $_cb_color_file
    or begin; rm -f $_cb_color_file.tmp; end
  '';

  # ── Pick a pair color via fzf ──
  _cb_pick_pair_color = ''
    set -l _cb_jq "${cb_jq}"
    set -l _cb_fzf "${cb_fzf}"
    set -l _cb_color_file "${cb_color_file}"
    set -l name ($_cb_jq -r '.[] | .[0]' $_cb_color_file \
      | $_cb_fzf --height 40% --layout=reverse --no-sort -e --border --cycle)
    if test -n "$name"
      $_cb_jq -r --arg k "$name" '.[] | select(.[0]==$k) | .[1]' $_cb_color_file
    end
  '';
}

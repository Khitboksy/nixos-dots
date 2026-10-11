{ lib, pkgs, ... }:
let
  inherit (lib) getExe getExe';

  rofi = getExe pkgs.rofi;
  slurp = getExe pkgs.slurp;
  ffmpeg = getExe pkgs.ffmpeg;
  notify-send = getExe' pkgs.libnotify "notify-send";
  recorder = getExe pkgs.wf-recorder;
in
{
  niri-record-toggle = pkgs.writeShellScriptBin "niri-record-toggle" ''
    # niri-record-toggle - Toggle wf-recorder region recording (Mod+Print)
    # First press: slurp region -> record to /tmp/recordings
    # Second press: SIGINT stop -> rofi filename prompt -> move to ~/media/videos
    # Escape at prompt: delete temp file
    # coreutils/procps assumed on PATH (global on NixOS); niche tools pinned
    set -euo pipefail

    TMP_DIR="/tmp/recordings"
    FINAL_DIR="$HOME/media/videos"

    mkdir -p "$TMP_DIR" "$FINAL_DIR"

    if pgrep -x wf-recorder > /dev/null 2>&1; then
      # --- STOP ---
      # SIGINT only: SIGTERM corrupts the mp4 muxer
      pkill -INT -x wf-recorder || true
      while pgrep -x wf-recorder > /dev/null 2>&1; do
        sleep 0.1
      done

      TMP_FILE="$(ls -t "$TMP_DIR"/*.mp4 2> /dev/null | head -n 1 || true)"
      if [[ -z "$TMP_FILE" ]]; then
        ${notify-send} "Recording" "Stopped, but no temp file was found"
        exit 1
      fi

      DEFAULT_NAME="recording-$(date +%Y-%m-%d-%H-%M-%S)"
      CHOSEN="$(printf '%s\n' "$DEFAULT_NAME" | ${rofi} -dmenu -p "Save as")" || CHOSEN=""

      # Escape / empty input: discard the temp file
      if [[ -z "$CHOSEN" ]]; then
        rm -f "$TMP_FILE"
        ${notify-send} "Recording" "Discarded (no name given)"
        exit 0
      fi

      if [[ "$CHOSEN" == *.gif ]]; then
        NAME="''${CHOSEN%.gif}"
        OUT="$FINAL_DIR/$NAME.gif"
        ${ffmpeg} -nostdin -y -i "$TMP_FILE" \
          -vf "fps=15,scale=1280:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
          "$OUT"
        rm -f "$TMP_FILE"
      else
        NAME="''${CHOSEN%.mp4}"
        OUT="$FINAL_DIR/$NAME.mp4"
        mv "$TMP_FILE" "$OUT"
      fi

      ${notify-send} "Recording saved" "$OUT"
    else
      # --- START ---
      GEO="$(${slurp})" || exit 0
      if [[ -z "$GEO" ]]; then
        exit 0
      fi

      FILE="$TMP_DIR/rec-$(date +%s).mp4"
      ${notify-send} "Recording started" "Press Mod+Print to stop"
      ${recorder} -y -g "$GEO" -f "$FILE" &
    fi
  '';
}

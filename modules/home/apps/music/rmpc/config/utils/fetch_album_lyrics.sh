#!/usr/bin/env bash
set -euo pipefail

# Config roots
MUSIC_ROOT="/mnt/nix-data/media/music"
LYRICS_ROOT="/mnt/nix-data/media/lyrics"

LRCLIB_API="https://lrclib.net/api/get"

usage() {
  echo "Usage:"
  echo "  $0 artist/album                   # fetch all songs in album"
  echo "  $0 --song /full/path/to/file.ext  # fetch lyrics for a single song"
  exit 1
}

# Get synced lyrics from LRCLIB API
get_lyrics_for() {
  local artist="$1"
  local album="$2"
  local title_try="$3"

  curl -sG \
    --data-urlencode "artist_name=${artist}" \
    --data-urlencode "track_name=${title_try}" \
    --data-urlencode "album_name=${album}" \
    "$LRCLIB_API" |
    jq -r '.syncedLyrics'
}

# Fetch lyrics for a single song
fetch_for_plain() {
  local artist="$1"
  local album="$2"
  local title_try="$3"
  local out_lrc="$4"

  # Skip if .lrc already exists
  [ -f "$out_lrc" ] && {
    echo "– Skipping \"$title_try\" (already have .lrc)"
    return 0
  }

  local lyrics
  lyrics="$(get_lyrics_for "$artist" "$album" "$title_try")"

  # Retry without parentheses
  if [ -z "$lyrics" ] || [ "$lyrics" == "null" ]; then
    local stripped
    stripped="$(echo "$title_try" | sed -E 's/ *\([^)]*\)//g')"
    if [ "$stripped" != "$title_try" ]; then
      title_try="$stripped"
      lyrics="$(get_lyrics_for "$artist" "$album" "$title_try")"
    fi
  fi

  if [ -z "$lyrics" ] || [ "$lyrics" == "null" ]; then
    echo "✗ No lyrics for: \"$title_try\""
    return 1
  fi

  mkdir -p "$(dirname "$out_lrc")"
  echo "$lyrics" | sed -E '/^\[(ar|al|ti):/d' >"$out_lrc"
  echo "✔ Saved lyrics: $(basename "$out_lrc")"
}

# Main logic
if [ $# -eq 2 ] && [ "$1" == "--song" ]; then
  SONG_PATH="$2"
  [ -f "$SONG_PATH" ] || {
    echo "File not found: $SONG_PATH"
    exit 1
  }

  # Determine artist/album from path
  REL_PATH="${SONG_PATH#$MUSIC_ROOT/}" # strip /music root
  ARTIST="$(echo "$REL_PATH" | cut -d/ -f1)"
  ALBUM="$(echo "$REL_PATH" | cut -d/ -f2)"
  filename="$(basename "$SONG_PATH")"
  TITLE_RAW="${filename%.*}"
  LRC_FILE="$LYRICS_ROOT/$ARTIST/$ALBUM/$TITLE_RAW.lrc"

  fetch_for_plain "$ARTIST" "$ALBUM" "$TITLE_RAW" "$LRC_FILE"
  exit 0
fi

# Album mode (existing behavior)
if [ $# -eq 1 ]; then
  ALBUM_REL="$1"
  ALBUM_DIR="$MUSIC_ROOT/$ALBUM_REL"
  [ -d "$ALBUM_DIR" ] || {
    echo "Album not found: $ALBUM_DIR"
    exit 1
  }

  ARTIST="$(basename "$(dirname "$ALBUM_DIR")")"
  ALBUM="$(basename "$ALBUM_DIR")"

  echo "▶ Fetching lyrics for all ".*" audio in: $ALBUM_DIR"
  echo "  Artist: $ARTIST"
  echo "  Album:  $ALBUM"
  echo

  shopt -s nullglob
  for file in "$ALBUM_DIR"/*.mp3 "$ALBUM_DIR"/*.flac; do
    [ -f "$file" ] || continue # skip if nothing matches
    filename="$(basename "$file")"
    TITLE_RAW="${filename%.*}" # <-- universal stripping
    LRC_FILE="$LYRICS_ROOT/$ARTIST/$ALBUM/$TITLE_RAW.lrc"
    fetch_for_plain "$ARTIST" "$ALBUM" "$TITLE_RAW" "$LRC_FILE"
  done

  echo
  echo "Done."
  exit 0
fi

usage

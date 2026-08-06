#!/usr/bin/env bash
set -uo pipefail

# Config roots
MUSIC_ROOT="/mnt/nix-data/media/music"
LYRICS_ROOT="/mnt/nix-data/media/lyrics"

LRCLIB_API="https://lrclib.net/api/get"

usage() {
  echo "Usage:"
  echo "  $0 artist/album                   # fetch all songs in album"
  echo "  $0 --song /full/path/to/file.ext  # fetch lyrics for a single song"
  echo "  (no args, \$FILE set)             # rmpc on_song_change hook mode"
  exit 1
}

get_lyrics_for() {
  local artist="$1"
  local album="$2"
  local title_try="$3"

  local args=(
    --data-urlencode "artist_name=${artist}"
    --data-urlencode "track_name=${title_try}"
  )
  [ -n "$album" ] && args+=(--data-urlencode "album_name=${album}")

  local resp
  resp="$(curl -sG --max-time 15 "${args[@]}" "$LRCLIB_API")" || return 1

  local synced plain
  synced="$(echo "$resp" | jq -r '.syncedLyrics // empty' 2>/dev/null)"
  if [ -n "$synced" ]; then
    echo "$synced"
    return 0
  fi

  plain="$(echo "$resp" | jq -r '.plainLyrics // empty' 2>/dev/null)"
  if [ -n "$plain" ]; then
    echo "$plain"
    return 0
  fi

  return 1
}

# Clean YouTube-ism noise from a title
clean_title() {
  local t="$1"
  # "2122 (Official Audio)" -> "2122"
  t="$(echo "$t" | sed -E 's/ *\([^)]*\)//g')"
  # "glass beach - plastic death - 01 coelacanth" -> "coelacanth"
  t="$(echo "$t" | sed -E 's/^.* - [0-9]{1,2} //')"
  # "01-By the Way" / "01.By the Way" / "16 Tell Me Baby" -> "Tell Me Baby"
  t="$(echo "$t" | sed -E 's/^[0-9]{1,2}[. -]+//')"
  # trim surrounding whitespace
  t="$(echo "$t" | sed -E 's/^[[:space:]]+|[[:space:]]+$//g')"
  echo "$t"
}

# PRIMARY metadata source: the artist/album directory tree, relative to $MUSIC_ROOT.
# For a loose file at artist level (no album dir) album comes back empty.
# Prints "artist|album|title"
tree_meta() {
  local song_path="$1"
  local rel rest d1 d2 filename
  rel="${song_path#$MUSIC_ROOT/}"
  d1="${rel%%/*}"
  rest="${rel#*/}"
  d2=""
  case "$rest" in
  */*) d2="${rest%%/*}" ;;
  esac
  filename="$(basename "$song_path")"
  echo "${d1}|${d2}|$(clean_title "${filename%.*}")"
}

# FALLBACK metadata source: file tags (ffprobe). Needed when the tree dir is
# an abbreviation LRCLIB doesn't know (e.g. dir "rhcp" vs canonical artist
# "Red Hot Chili Peppers"). Prints "artist|album|title" (may be empty fields).
probe_meta() {
  local song_path="$1"
  local filename
  local artist="" album="" title=""
  if command -v ffprobe >/dev/null 2>&1; then
    artist="$(ffprobe -v quiet -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$song_path" 2>/dev/null)"
    album="$(ffprobe -v quiet -show_entries format_tags=album -of default=noprint_wrappers=1:nokey=1 "$song_path" 2>/dev/null)"
    title="$(ffprobe -v quiet -show_entries format_tags=title -of default=noprint_wrappers=1:nokey=1 "$song_path" 2>/dev/null)"
  fi
  filename="$(basename "$song_path")"
  [ -z "$title" ] && title="$(clean_title "${filename%.*}")"
  echo "${artist}|${album}|${title}"
}

# Fetch lyrics for a single song, trying candidates in order until one hits.
#   $1 artist (tree-derived, primary)
#   $2 album  (tree-derived, primary; may be empty)
#   $3 title  (tree-derived, primary)
#   $4 out_lrc (target .lrc path - MIRRORS the music file path so rmpc's
#               filename-based lookup works)
#   $5 alt_artist $6 alt_album $7 alt_title (ffprobe fallback set; may be empty)
# Order: tree+album -> tree w/o album -> tree+cleaned title -> probe set.
# On success the [ar:]/[al:]/[ti:] headers use whichever candidate matched.
fetch_for_plain() {
  local artist="$1"
  local album="$2"
  local title_try="$3"
  local out_lrc="$4"
  local alt_artist="${5:-}"
  local alt_album="${6:-}"
  local alt_title="${7:-}"

  if [ -f "$out_lrc" ]; then
    echo "- Skipping \"$title_try\" (already have .lrc)"
    return 0
  fi

  local lyrics=""
  local cleaned=""

  # 1. Primary contract: tree artist + album + track
  lyrics="$(get_lyrics_for "$artist" "$album" "$title_try")"

  # 2. LRCLIB's album param is flaky - retry without it
  if [ -z "$lyrics" ]; then
    lyrics="$(get_lyrics_for "$artist" "" "$title_try")"
  fi

  # 3. Cleaned title (strip (Official...), track prefixes, artist/album prefixes)
  if [ -z "$lyrics" ]; then
    cleaned="$(clean_title "$title_try")"
    if [ -n "$cleaned" ] && [ "$cleaned" != "$title_try" ]; then
      lyrics="$(get_lyrics_for "$artist" "$album" "$cleaned")"
      [ -z "$lyrics" ] && lyrics="$(get_lyrics_for "$artist" "" "$cleaned")"
    fi
  fi

  # 4. ffprobe fallback set (legacy dirs where tree name != canonical artist)
  if [ -z "$lyrics" ] && [ -n "$alt_artist" ] && [ "$alt_artist" != "$artist" ]; then
    artist="$alt_artist"
    [ -n "$alt_album" ] && album="$alt_album"
    [ -n "$alt_title" ] && title_try="$alt_title"
    lyrics="$(get_lyrics_for "$artist" "$album" "$title_try")"
    [ -z "$lyrics" ] && lyrics="$(get_lyrics_for "$artist" "" "$title_try")"
  fi

  if [ -z "$lyrics" ]; then
    echo "x No lyrics for: \"$title_try\" (artist: $artist)"
    return 0
  fi

  mkdir -p "$(dirname "$out_lrc")"

  # Write our own [ti:]/[ar:]/[al:] headers - these power rmpc's tag-based
  # lyric index (fallback to the filename-based lookup).
  {
    printf '[ti: %s]\n' "$title_try"
    printf '[ar: %s]\n' "$artist"
    if [ -n "$album" ] && [ "$album" != "$title_try" ]; then
      printf '[al: %s]\n' "$album"
    fi
    echo ""
    echo "$lyrics"
  } >"$out_lrc"
  echo "v Saved lyrics: $(basename "$out_lrc")"
}

# Output .lrc path for a music file: mirrors its path under MUSIC_ROOT into LYRICS_ROOT.
mirror_lrc_path() {
  local song_path="$1"
  local rel
  rel="${song_path#$MUSIC_ROOT/}"
  echo "$LYRICS_ROOT/${rel%.*}.lrc"
}

# ---------------------------------------------------------------- main

# Mode 1: rmpc on_song_change hook - env vars only, no CLI args.
#   Fast path: if the playing song already has a .lrc, or the album was already
#   scanned and found no lyrics (marked with a .nolyrics file), do nothing -
#   this runs on EVERY track change, so it must be cheap (no network, no scan).
#   Slow path: no .lrc for the playing song -> background a serialized,
#   lock-guarded cascade over the whole album dir (flat, non-recursive) that
#   fetches a .lrc for every song in the album missing one, named identically
#   via mirror_lrc_path. rmpc's hot-reload picks them up as tracks play.
if [ $# -eq 0 ] && [ -n "${FILE:-}" ]; then
  # $FILE is relative to the music dir; $LRC_FILE is the exact path rmpc will
  # look up (filename-based). Artist/album/title resolve TREE-FIRST (d1/d2 of
  # the path), with ffprobe tags as the fallback for legacy abbreviated dirs.
  SONG_PATH="${MUSIC_ROOT}/${FILE}"
  LRC_FILE="${LRC_FILE:-$(mirror_lrc_path "$SONG_PATH")}"

  # Fast path: already have lyrics, or already confirmed the album has none.
  if [ -f "$LRC_FILE" ] || [ -f "$(dirname "$LRC_FILE")/.nolyrics" ]; then
    exit 0
  fi

  # Slow path: playing song lacks lyrics. Fire-and-forget the album cascade so
  # the hook returns instantly (rmpc's UI never blocks). Serialized via flock -
  # a second trigger while a cascade runs waits for it, then skips re-fetching
  # anything already written.
  {
    flock 9 || exit 0
    ALBUM_DIR="$(dirname "$SONG_PATH")"
    # Mirror of the album dir under the lyrics root (may not exist yet)
    LYRIC_ALBUM_DIR="${LYRICS_ROOT}/${ALBUM_DIR#$MUSIC_ROOT/}"

    echo "> Hook: no lyrics for $FILE - scanning album $ALBUM_DIR"
    wrote_any=0
    shopt -s nullglob
    for file in "$ALBUM_DIR"/*.mp3 "$ALBUM_DIR"/*.flac; do
      [ -f "$file" ] || continue # skip if nothing matches
      IFS='|' read -r t_artist t_album t_title <<<"$(tree_meta "$file")"
      IFS='|' read -r p_artist p_album p_title <<<"$(probe_meta "$file")"
      LRC_FILE="$(mirror_lrc_path "$file")"
      if [ -f "$LRC_FILE" ]; then
        echo "- Skipping \"$t_title\" (already have .lrc)"
        wrote_any=1
        continue
      fi
      before="$(find "$LYRIC_ALBUM_DIR" -name '*.lrc' 2>/dev/null | wc -l)"
      fetch_for_plain "$t_artist" "$t_album" "$t_title" "$LRC_FILE" \
        "$p_artist" "$p_album" "$p_title"
      after="$(find "$LYRIC_ALBUM_DIR" -name '*.lrc' 2>/dev/null | wc -l)"
      [ "$after" -gt "$before" ] && wrote_any=1
    done

    # If nothing was found across the whole album, remember that so we don't
    # re-scan it on every subsequent song change. Delete the marker manually
    # if lyrics become available later.
    if [ "$wrote_any" -eq 0 ]; then
      mkdir -p "$LYRIC_ALBUM_DIR"
      : >"$LYRIC_ALBUM_DIR/.nolyrics"
      echo "> Hook: no lyrics anywhere in album - marked .nolyrics"
    fi
    echo "> Hook: album scan done"
  } 9>"${XDG_RUNTIME_DIR:-/tmp}/rmpc-fetch-lyrics.lock" \
    >>"${XDG_RUNTIME_DIR:-/tmp}/rmpc-fetch-lyrics.log" 2>&1 &
  disown
  exit 0
fi

# Mode 2: explicit single song
if [ $# -eq 2 ] && [ "$1" == "--song" ]; then
  SONG_PATH="$2"
  [ -f "$SONG_PATH" ] || {
    echo "File not found: $SONG_PATH"
    exit 1
  }

  IFS='|' read -r t_artist t_album t_title <<<"$(tree_meta "$SONG_PATH")"
  IFS='|' read -r p_artist p_album p_title <<<"$(probe_meta "$SONG_PATH")"
  LRC_FILE="$(mirror_lrc_path "$SONG_PATH")"

  fetch_for_plain "$t_artist" "$t_album" "$t_title" "$LRC_FILE" \
    "$p_artist" "$p_album" "$p_title"
  exit 0
fi

# Mode 3: album mode
if [ $# -eq 1 ]; then
  ALBUM_REL="$1"
  ALBUM_DIR="$MUSIC_ROOT/$ALBUM_REL"
  [ -d "$ALBUM_DIR" ] || {
    echo "Album not found: $ALBUM_DIR"
    exit 1
  }

  dir_artist="$(basename "$(dirname "$ALBUM_DIR")")"
  dir_album="$(basename "$ALBUM_DIR")"

  echo "> Fetching lyrics for audio in: $ALBUM_DIR"
  echo "  Artist: $dir_artist"
  echo "  Album:  $dir_album"
  echo

  shopt -s nullglob
  for file in "$ALBUM_DIR"/*.mp3 "$ALBUM_DIR"/*.flac; do
    [ -f "$file" ] || continue # skip if nothing matches
    IFS='|' read -r t_artist t_album t_title <<<"$(tree_meta "$file")"
    IFS='|' read -r p_artist p_album p_title <<<"$(probe_meta "$file")"
    LRC_FILE="$(mirror_lrc_path "$file")"
    fetch_for_plain "$t_artist" "$t_album" "$t_title" "$LRC_FILE" \
      "$p_artist" "$p_album" "$p_title"
  done

  echo
  echo "Done."
  exit 0
fi

usage

#!/usr/bin/env bash
set -uo pipefail

# Config roots: env var > hostname > Helios default
if [ -n "${YTBLK_MUSIC_DIR:-}" ]; then
  MUSIC_ROOT="$YTBLK_MUSIC_DIR"
  LYRICS_ROOT="${YTBLK_LYRICS_DIR:-$(dirname "$MUSIC_ROOT")/lyrics}"
elif [ "$(hostname)" = "terra" ]; then
  MUSIC_ROOT="/srv/music"
  LYRICS_ROOT="/srv/lyrics"
else
  MUSIC_ROOT="/mnt/nix-data/media/music"
  LYRICS_ROOT="/mnt/nix-data/media/lyrics"
fi

usage() {
  echo "Usage:"
  echo "  $0 artist/album                   # fetch all songs in album"
  echo "  $0 --song /full/path/to/file.ext  # fetch lyrics for a single song"
  echo "  $0 --rmpcd FILE TITLE ARTIST ALBUM DURATION  # rmpcd plugin mode"
  echo "  (no args, \$FILE set)             # rmpc on_song_change hook mode"
  exit 1
}

DANKLRC="${DANKLRC:-danklrc}"

get_lyrics_for() {
  local artist="$1"
  local album="$2"
  local title_try="$3"
  local out="$4"

  local args=(-title "$title_try" -artist "$artist" -out "$out")
  [ -n "$album" ] && args+=(-album "$album")
  case "${DURATION:-}" in
  '' | *[!0-9]*) ;; # empty or non-numeric: unknown
  0) ;;             # 0 = unknown
  *) args+=(-duration "$DURATION") ;;
  esac
  if [ -n "${SONG_PATH:-}" ] && [ -f "${SONG_PATH:-}" ]; then
    args+=(-file "$SONG_PATH")
  fi

  "$DANKLRC" "${args[@]}"
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

# Whole seconds of audio duration for a file; empty when unknown.
probe_duration() {
  local d=""
  if command -v ffprobe >/dev/null 2>&1; then
    d="$(ffprobe -v quiet -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$1" 2>/dev/null)"
  fi
  d="${d%%.*}"
  case "$d" in
  '' | *[!0-9]*) ;;
  *) echo "$d" ;;
  esac
}

# Normalize rmpc's $DURATION to whole seconds. Depending on rmpc's Song type
# it may be a bare integer ("253"), a Rust Duration Display ("253.456789012s"),
# or empty (streams). Anything unrecognized comes back empty = unknown.
dur_secs() {
  local d="${1:-}"
  d="${d%s}"
  d="${d%%.*}"
  case "$d" in
  '' | *[!0-9]*) ;;
  *) echo "$d" ;;
  esac
}

# Fetch lyrics for a single song, trying candidates in order until one hits.
#   $1 artist (tree-derived, primary)
#   $2 album  (tree-derived, primary; may be empty)
#   $3 title  (tree-derived, primary)
#   $4 out_lrc (target .lrc path - MIRRORS the music file path so rmpc's
#               filename-based lookup works)
#   $5 alt_artist $6 alt_album $7 alt_title (ffprobe fallback set; may be empty)
# Uses globals SONG_PATH (audio file) and DURATION (seconds, may be empty),
# set per-file by the caller.
# Order: tree+album -> tree w/o album -> tree+cleaned title -> probe set.
# danklrc writes $4 itself (headers included) when a candidate matches.
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

  local cleaned=""

  # 1. Primary contract: tree artist + album + track
  get_lyrics_for "$artist" "$album" "$title_try" "$out_lrc"

  # 2. The album param can be flaky - retry without it
  if [ ! -f "$out_lrc" ]; then
    get_lyrics_for "$artist" "" "$title_try" "$out_lrc"
  fi

  # 3. Cleaned title (strip (Official...), track prefixes, artist/album prefixes)
  if [ ! -f "$out_lrc" ]; then
    cleaned="$(clean_title "$title_try")"
    if [ -n "$cleaned" ] && [ "$cleaned" != "$title_try" ]; then
      get_lyrics_for "$artist" "$album" "$cleaned" "$out_lrc"
      [ ! -f "$out_lrc" ] && get_lyrics_for "$artist" "" "$cleaned" "$out_lrc"
    fi
  fi

  # 4. ffprobe fallback set (legacy dirs where tree name != canonical artist)
  if [ ! -f "$out_lrc" ] && [ -n "$alt_artist" ] && [ "$alt_artist" != "$artist" ]; then
    get_lyrics_for "$alt_artist" "$alt_album" "$alt_title" "$out_lrc"
    [ ! -f "$out_lrc" ] && get_lyrics_for "$alt_artist" "" "$alt_title" "$out_lrc"
  fi

  if [ ! -f "$out_lrc" ]; then
    echo "x No lyrics for: \"$title_try\" (artist: $artist)"
    return 0
  fi

  echo "v Saved lyrics: $(basename "$out_lrc")"
  link_navidrome_symlink "$out_lrc"
}

# Output .lrc path for a music file: mirrors its path under MUSIC_ROOT into LYRICS_ROOT.
mirror_lrc_path() {
  local song_path="$1"
  local rel
  rel="${song_path#$MUSIC_ROOT/}"
  echo "$LYRICS_ROOT/${rel%.*}.lrc"
}

# Create the navidrome sidecar symlink inside the music library so terra's
# navidrome can serve these lyrics to Substreamer. Navidrome only reads .lrc
# files co-located with the audio file (same basename, same directory); there
# is no separate-lyrics-folder option. The real .lrc stays in the LYRICS_ROOT
# mirror; we drop a RELATIVE symlink next to the song:
#   /srv/music/Artist/Album/Song.lrc -> ../../../lyrics/Artist/Album/Song.lrc
# Relative targets resolve from BOTH hosts because music/ and lyrics/ are
# sibling trees with identical layout:
#   terra : /srv/{music,lyrics}
#   helios: /mnt/nix-data/media/{music,lyrics}  (both NFS mounts)
link_navidrome_symlink() {
  local lrc_path="$1"
  [ -f "$lrc_path" ] || return 0

  local rel song_path link_path target
  rel="${lrc_path#$LYRICS_ROOT/}"   # Artist/Album/Song.lrc
  song_path="$MUSIC_ROOT/${rel%.*}" # Artist/Album/Song (ext varies)
  # Only link songs that exist in the library
  if [ ! -f "$song_path.mp3" ] && [ ! -f "$song_path.flac" ]; then
    return 0
  fi

  link_path="$MUSIC_ROOT/$rel"
  target="$(realpath --relative-to "$(dirname "$link_path")" "$lrc_path")" || return 0
  mkdir -p "$(dirname "$link_path")"
  ln -sfn "$target" "$link_path"
}

# Tell every running rmpc to (re)index a lyrics file immediately. rmpc's
# lyrics watcher only reacts to Close(Write), but danklrc atomic-renames
# files into place, so without this nudge a late-written .lrc stays
# invisible until the next track change. Broadcast (no --pid) reaches
# every running rmpc - same call rmpcd's builtin lyrics plugin makes.
announce_lyrics() {
  [ -f "${1:-}" ] || return 0
  "${RMPC:-rmpc}" remote indexlrc --path "$1" >/dev/null 2>&1 || true
}

# main ----------------------------------------------------------------

# Mode 0: rmpcd plugin - MPD-relative path plus authoritative metadata.
#   argv: --rmpcd FILE TITLE ARTIST ALBUM DURATION_SECS
#   Rewrites into the same variables Mode 1 consumes, then falls through so
#   both triggers (rmpc's on_song_change hook and rmpcd's song_change) share
#   one code path. flock in the slow path keeps them from double-fetching.
if [ $# -eq 6 ] && [ "$1" == "--rmpcd" ]; then
  FILE="$2"
  TITLE="${3:-}"
  ARTIST="${4:-}"
  ALBUM="${5:-}"
  DURATION="${6:-}"
  set --
fi

# Mode 1: rmpc on_song_change hook / rmpcd - env-style inputs, no CLI args.
#   Fast path: if the playing song already has a .lrc, or the album was already
#   scanned and found no lyrics (marked with a .nolyrics file), do nothing -
#   this runs on EVERY track change, so it must be cheap (no network, no scan).
#   Slow path: no .lrc for the playing song -> background a serialized attempt
#   with MPD metadata (TITLE/ARTIST from rmpc's tag env or rmpcd's args),
#   followed by the album cascade over every track still missing a .lrc,
#   named identically via mirror_lrc_path. Late-written files are announced to
#   rmpc via `rmpc remote indexlrc` (atomic renames bypass its FS watcher).
if [ $# -eq 0 ] && [ -n "${FILE:-}" ]; then
  # Network streams have no local file or mirror path - nothing to fetch.
  case "$FILE" in
  *://*) exit 0 ;;
  esac

  DURATION="$(dur_secs "${DURATION:-}")"
  # $FILE is relative to the music dir; $LRC_FILE is the exact path rmpc will
  # look up (filename-based).
  SONG_PATH="${MUSIC_ROOT}/${FILE}"
  LRC_FILE="${LRC_FILE:-$(mirror_lrc_path "$SONG_PATH")}"
  # The cascade below overwrites LRC_FILE per file; keep the playing song's
  # path so we can announce it to rmpc once the fetch finishes.
  PLAYING_LRC="$LRC_FILE"

  # Fast path: already have lyrics, or already confirmed the album has none.
  if [ -f "$LRC_FILE" ] || [ -f "$(dirname "$LRC_FILE")/.nolyrics" ]; then
    exit 0
  fi

  # Slow path: playing song lacks lyrics. Fire-and-forget the work so the
  # hook returns instantly (rmpc's UI never blocks). Serialized via flock -
  # a second trigger while a cascade runs waits for it, then skips re-fetching
  # anything already written.
  {
    flock 9 || exit 0
    ALBUM_DIR="$(dirname "$SONG_PATH")"
    # Mirror of the album dir under the lyrics root (may not exist yet)
    LYRIC_ALBUM_DIR="${LYRICS_ROOT}/${ALBUM_DIR#$MUSIC_ROOT/}"

    wrote_any=0

    # 1. Authoritative metadata first: rmpc exports MPD tags uppercased
    #    ($TITLE/$ARTIST/$ALBUM) and rmpcd passes them via --rmpcd. One
    #    danklrc attempt with real tags beats directory guessing.
    if [ -n "${TITLE:-}" ] && [ -n "${ARTIST:-}" ]; then
      echo "> Hook: explicit fetch for $FILE"
      fetch_for_plain "$ARTIST" "${ALBUM:-}" "$TITLE" "$LRC_FILE"
      [ -f "$LRC_FILE" ] && wrote_any=1
      # The playing song is ready now - show it BEFORE the cascade runs,
      # not after it finishes.
      announce_lyrics "$PLAYING_LRC"
    fi

    # 2. Cascade: every track in the album dir (flat, non-recursive) still
    #    missing a .lrc, tree/ffprobe metadata. Also re-tries the playing
    #    song with tree metadata if the explicit attempt above missed.
    echo "> Hook: scanning album $ALBUM_DIR"
    shopt -s nullglob
    for file in "$ALBUM_DIR"/*.mp3 "$ALBUM_DIR"/*.flac; do
      [ -f "$file" ] || continue # skip if nothing matches
      # Skip BEFORE probing: ffprobe per track costs ~1.5s each, and this
      # loop runs on every queued trigger even when nothing is missing.
      LRC_FILE="$(mirror_lrc_path "$file")"
      if [ -f "$LRC_FILE" ]; then
        IFS='|' read -r _ _ t_title <<<"$(tree_meta "$file")"
        echo "- Skipping \"$t_title\" (already have .lrc)"
        wrote_any=1
        continue
      fi
      IFS='|' read -r t_artist t_album t_title <<<"$(tree_meta "$file")"
      IFS='|' read -r p_artist p_album p_title <<<"$(probe_meta "$file")"
      SONG_PATH="$file"
      DURATION="$(probe_duration "$file")"
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

    # Fallback announce: the cascade may have written the playing song's
    # .lrc when the explicit attempt above missed (tree metadata vs tags).
    announce_lyrics "$PLAYING_LRC"
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
  DURATION="$(probe_duration "$SONG_PATH")"

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
    # Skip before probing, same as the cascade loop above.
    LRC_FILE="$(mirror_lrc_path "$file")"
    if [ -f "$LRC_FILE" ]; then
      IFS='|' read -r _ _ t_title <<<"$(tree_meta "$file")"
      echo "- Skipping \"$t_title\" (already have .lrc)"
      continue
    fi
    IFS='|' read -r t_artist t_album t_title <<<"$(tree_meta "$file")"
    IFS='|' read -r p_artist p_album p_title <<<"$(probe_meta "$file")"
    SONG_PATH="$file"
    DURATION="$(probe_duration "$file")"
    fetch_for_plain "$t_artist" "$t_album" "$t_title" "$LRC_FILE" \
      "$p_artist" "$p_album" "$p_title"
  done

  echo
  echo "Done."
  exit 0
fi

usage

{
  lib,
  ffmpeg,
  ...
}:

with lib;

{
  retag = ''
    set -l base /mnt/nix-data/media/music
    set -l dry_run 0
    set -l artist ""
    set -l album ""
    set -l track_file ""
    set -l e_artist ""
    set -l e_album ""
    set -l e_title ""
    set -l e_year ""
    set -l e_track ""
    set -l pre_args
    set -l edit_args
    set -l after_sep 0

    # Split argv on the first `--`
    for a in $argv
      if test $after_sep -eq 0; and test "$a" = "--"
        set after_sep 1
        continue
      end
      if test $after_sep -eq 1
        set -a edit_args $a
      else
        set -a pre_args $a
      end
    end

    # ---- path section (before --) ----
    set -l args $pre_args
    while test (count $args) -gt 0
      switch $args[1]
        case --artist
          set -e args[1]; or return 1
          test (count $args) -ge 1; or begin; echo "missing value for --artist"; return 1; end
          set artist $args[1]
        case --album
          set -e args[1]; or return 1
          test (count $args) -ge 1; or begin; echo "missing value for --album"; return 1; end
          set album $args[1]
        case --track
          set -e args[1]; or return 1
          test (count $args) -ge 1; or begin; echo "missing value for --track"; return 1; end
          set track_file $args[1]
        case --dry-run
          set dry_run 1
        case '-*'
          echo "unknown path option: $args[1]"
          echo "usage: retag [--dry-run] --artist <artist> --album <album> [--track <file>] -- [edit options]"
          return 1
        case '*'
          echo "unexpected argument before '--': $args[1]"
          echo "usage: retag [--dry-run] --artist <artist> --album <album> [--track <file>] -- [edit options]"
          return 1
      end
      set -e args[1]
    end

    if test -z "$artist"; or test -z "$album"
      echo "usage: retag [--dry-run] --artist <artist> --album <album> [--track <file>] -- [edit options]"
      return 1
    end

    # Resolve artist dir (exact match; list candidates on miss)
    set -l artist_dir "$base/$artist"
    if not test -d "$artist_dir"
      echo "artist not found: $artist"
      echo "candidates under $base:"
      set -l hits
      for d in (ls "$base" 2>/dev/null)
        if string match -q "*$artist*" -- "$d"
          set -a hits "$d"
        end
      end
      if test (count $hits) -eq 0
        echo "  (no matching artist dirs)"
      else
        for d in $hits
          echo "  $d"
        end
      end
      return 1
    end

    set -l album_dir "$artist_dir/$album"
    if not test -d "$album_dir"
      echo "album not found: $album"
      echo "candidates under $artist_dir:"
      set -l hits
      for d in (ls "$artist_dir" 2>/dev/null)
        if string match -q "*$album*" -- "$d"
          set -a hits "$d"
        end
      end
      if test (count $hits) -eq 0
        echo "  (no matching album dirs)"
      else
        for d in $hits
          echo "  $d"
        end
      end
      return 1
    end

    # Resolve targets: single --track file, or all audio in the album dir
    set -l targets
    if test -n "$track_file"
      set -l f "$album_dir/$track_file"
      if test -f "$f"
        set -a targets "$f"
      else
        echo "track not found: $track_file"
        echo "files in $album_dir:"
        for e in (ls "$album_dir" 2>/dev/null)
          echo "  $e"
        end
        return 1
      end
    else
      for ext in mp3 flac ogg m4a
        for f in "$album_dir"/*.$ext
          test -f "$f"; and set -a targets "$f"
        end
      end
      if test (count $targets) -eq 0
        echo "no audio files found in $album_dir"
        return 1
      end
    end

    # ---- edit section (after --) ----
    set -l args $edit_args
    while test (count $args) -gt 0
      switch $args[1]
        case --year -y
          set -e args[1]; or return 1
          test (count $args) -ge 1; or begin; echo "missing value for --year"; return 1; end
          set e_year $args[1]
        case --artist -art
          set -e args[1]; or return 1
          test (count $args) -ge 1; or begin; echo "missing value for --artist"; return 1; end
          set e_artist $args[1]
        case --album -alb
          set -e args[1]; or return 1
          test (count $args) -ge 1; or begin; echo "missing value for --album"; return 1; end
          set e_album $args[1]
        case --track -tr
          set -e args[1]; or return 1
          test (count $args) -ge 1; or begin; echo "missing value for --track"; return 1; end
          if not string match -rq '^[0-9]+$' -- "$args[1]"
            echo "track number must be numeric: $args[1]"
            return 1
          end
          set e_track $args[1]
        case --title -ti
          set -e args[1]; or return 1
          test (count $args) -ge 1; or begin; echo "missing value for --title"; return 1; end
          set e_title $args[1]
        case '-*'
          echo "unknown edit option: $args[1]"
          return 1
        case '*'
          echo "unexpected argument after '--': $args[1]"
          return 1
      end
      set -e args[1]
    end

    # Build ffmpeg metadata args
    set -l meta
    test -n "$e_artist"; and set -a meta "-metadata" "artist=$e_artist"
    test -n "$e_album";  and set -a meta "-metadata" "album=$e_album"
    test -n "$e_title";  and set -a meta "-metadata" "title=$e_title"
    test -n "$e_year";   and set -a meta "-metadata" "date=$e_year"
    test -n "$e_track";  and set -a meta "-metadata" "track=$e_track"

    if test (count $meta) -eq 0
      echo "nothing to set (edit options after '--': --artist|-art --album|-alb --title|-ti --year|-y --track|-tr)"
      return 1
    end

    if test $dry_run -eq 1
      echo "[dry-run] album dir: $album_dir"
      for t in $targets
        echo "[dry-run]   $t"
      end
      echo "[dry-run] metadata: $meta"
      return 0
    end

    echo "album: $album_dir"
    for t in $targets
      echo "  $t"
    end
    echo "metadata: $meta"

    # ffmpeg remuxes to a temp file then replaces the original (in-place).
    for t in $targets
      set -l tmp "$t.retag_tmp"(path extension $t)
      ${getExe ffmpeg} -v error -y -i "$t" -c copy $meta "$tmp"
      if test $status -eq 0
        mv -f "$tmp" "$t"
        echo "  ok: $t"
      else
        rm -f "$tmp"
        echo "  FAILED: $t"
      end
    end
  '';
}

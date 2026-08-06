{
  lib,
  ffmpeg,
  yt-dlp,
  ...
}:

with lib;

{
  ytbulk = ''

    set BASE_DIR /mnt/nix-data/media/music

    read -P "How many albums would you like to add? " album_count

    if not string match -rq '^[0-9]+$' -- $album_count
        echo "Please enter a valid number."
        return 1
    end

    set artists
    set albums
    set links

    for i in (seq 1 $album_count)
        read -P "Album $i - artist: " artist
        read -P "Album $i - album name: " album
        read -P "Album $i - YouTube link (album/playlist): " link
        set -a artists $artist
        set -a albums $album
        set -a links $link
    end

    echo ""
    echo "========== CONFIRMATION =========="
    for i in (seq 1 (count $artists))
        echo "  $BASE_DIR/$artists[$i]/$albums[$i]/"
        echo "  link: $links[$i]"
        echo ""
    end

    read -P "Proceed? (y/n): " confirm
    if test "$confirm" != "y"
        echo "Aborted."
        return 0
    end

    # Ensure base directory exists
    if not test -d "$BASE_DIR"
        echo "Base directory $BASE_DIR does not exist."
        return 1
    end

    for i in (seq 1 (count $artists))
        set artist "$artists[$i]"
        set album "$albums[$i]"
        set link "$links[$i]"
        set target_dir "$BASE_DIR/$artist/$album"

        # Forbid path traversal / absolute sneaking in artist/album names.
        if string match -rq '/|\$|~|\.\.' -- "$artist$album"
            echo "Skipping $artist/$album - bad character in name"
            continue
        end

        mkdir -p "$target_dir"; or begin
            echo "Failed creating $target_dir"
            continue
        end

        set tmp_dir "$target_dir/.$album.ytmp"
        mkdir -p "$tmp_dir"

        echo ""
        echo "Downloading: $artist - $album (into $tmp_dir)..."

        cd "$tmp_dir"; or begin
            echo "Failed to enter $tmp_dir - skipping"
            continue
        end

        ${getExe yt-dlp} \
            -x \
            --audio-format mp3 \
            --embed-metadata \
            --embed-thumbnail \
            --ignore-errors \
            --no-overwrites \
            --concurrent-fragments 8 \
            -o "%(autonumber)03d-%(id)s.%(ext)s" \
            $link

        if test $status -ne 0
            echo "Warning: some items failed in $link - ignored"
        end

        # --- rename + tag each downloaded file ---
        set tmp_files
        for f in $tmp_dir/*.mp3 $tmp_dir/*.m4a $tmp_dir/*.flac
            test -f "$f"; and set -a tmp_files "$f"
        end
        set total (count $tmp_files)
        set track 0
        for f in $tmp_files
            set track (math $track + 1)
            set tracknum (printf "%02d" $track)
            set ext (string split -r -m1 . -- "$f")[2]
            set base_name (basename "$f")

            # Real title comes from the embedded metadata
            set title_raw (${getExe' ffmpeg "ffprobe"} -v quiet \
                -show_entries format_tags=title \
                -of default=noprint_wrappers=1:nokey=1 "$f")
            if test -z "$title_raw"
                set title_raw (echo $base_name | string replace -r '^[0-9]{3}-' "")
            end

            set title_clean (echo "$title_raw" \
                | string replace -ri ' *\((official audio|official music video|official video|music video|official lyrics|lyrics video)\)$' "" \
                | string trim \
                | string replace -ra '[[:space:]]+' ' ')
            if test -z "$title_clean"
                set title_clean (string replace -ra '/' '_' -- (basename "$f" . $ext))
            end

            set filename_title (echo "$title_clean" \
                | string replace -ri ' (official video|official audio|official music video|music video|official lyrics|lyrics video|lyric video) *$' "" \
                | string trim \
                | string replace -ra '[[:space:]]+' ' ' \
                | string replace -ra '/' '_')

            set out_file "$target_dir/$tracknum $filename_title.$ext"

            echo "  tagging -> $artist - $album - $tracknum $filename_title.$ext"

            ${getExe ffmpeg} -v error -y -i "$f" \
                -c copy \
                -metadata artist="$artist" \
                -metadata album="$album" \
                -metadata title="$title_clean" \
                -metadata track="$track" \
                -metadata tracktotal="$total" \
                -metadata description= \
                -metadata synopsis= \
                -metadata comment= \
                "$out_file"

            if test $status -eq 0
                rm -f "$f"
                echo "    ok: $tracknum $filename_title.$ext"
            else
                echo "    FAILED: $base_name"
            end
        end

        # Tidy the temp dir
        rmdir "$tmp_dir" 2>/dev/null; or echo "  leftover files in $tmp_dir"
    end

    echo ""
    echo "All downloads complete."
  '';
}

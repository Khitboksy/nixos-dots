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

    # --- queue collection: one or more artist batches ---
    set artists
    set kinds
    set albums
    set links

    set q_done 0
    # Start of queue loop, only breaks when `q_done = 1`
    while test $q_done -eq 0
        # 1. ask once
        read -P "artist: " artist
        # 2. set loop count
        read -P "How many objects to create: " obj_count
        if not string match -rq '^[0-9]+$' -- $obj_count
            echo "Please enter a valid number."
            continue
        end

        # 3. Loop for N many objects ---
        for i in (seq 1 $obj_count)
            read -P "Link for Music: " link
            read -P "Album or Single? (a/s): " kind
            set album ""
            if test "$kind" = "a"; or test "$kind" = "album"
                read -P "Album Name: " album
            end
            set -a artists $artist
            set -a kinds $kind
            set -a albums $album
            set -a links $link
        end

        # 4. `q_done`, if 0 return to step one, if 1 break for confirmation
        read -P "Done? (y/n): " done_ans
        if test "$done_ans" = "y"
            set q_done 1
        end
    end

    echo ""
    echo "========== CONFIRMATION =========="
    for i in (seq 1 (count $artists))
        if test "$kinds[$i]" = "a"; or test "$kinds[$i]" = "album"
            echo "  album : $BASE_DIR/$artists[$i]/$albums[$i]/"
        else
            echo "  single: $BASE_DIR/$artists[$i]/"
        end
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
        set kind "$kinds[$i]"
        set album "$albums[$i]"
        set link "$links[$i]"
        set is_album 0
        if test "$kind" = "a"; or test "$kind" = "album"
            set is_album 1
        end

        if test $is_album -eq 1
            set target_dir "$BASE_DIR/$artist/$album"
            set tmp_dir "$target_dir/.$album.ytmp"
        else
            set target_dir "$BASE_DIR/$artist"
            set tmp_dir "$target_dir/.single.ytmp"
        end

        # Forbid path traversal / absolute sneaking in artist/album names.
        if string match -rq '/|\$|~|\.\.' -- "$artist$album"
            echo "Skipping $artist/$album - bad character in name"
            continue
        end

        mkdir -p "$target_dir"; or begin
            echo "Failed creating $target_dir"
            continue
        end

        mkdir -p "$tmp_dir"

        echo ""
        if test $is_album -eq 1
            echo "Downloading: $artist - $album (into $tmp_dir)..."
        else
            echo "Downloading: $artist (single, into $tmp_dir)..."
        end

        ${getExe yt-dlp} \
            -q \
            --no-warnings \
            --no-progress \
            --print "before_dl:Downloading %(title)s..." \
            -x \
            --audio-format mp3 \
            --embed-metadata \
            --embed-thumbnail \
            --ignore-errors \
            --no-overwrites \
            --concurrent-fragments 8 \
            -P "$tmp_dir" \
            -o "%(autonumber)03d-%(id)s.%(ext)s" \
            $link

        if test $status -ne 0
            echo "Warning: some items failed in $link - ignored"
        end

        echo "Done!"

        # --- rename + tag each downloaded file ---
        set tmp_files
        for f in $tmp_dir/*.mp3 $tmp_dir/*.m4a $tmp_dir/*.flac
            test -f "$f"; and set -a tmp_files "$f"
        end
        set total (count $tmp_files)
        set track 0
        echo "Renaming, and moving tracks...."
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

            # Albums: NN Title.ext, full album metadata.
            # Singles: Title.ext (no track number); if more than one file
            # slipped in, number them so nothing collides.
            if test $is_album -eq 1
                set out_file "$target_dir/$tracknum $filename_title.$ext"
            else if test $total -gt 1
                set out_file "$target_dir/$tracknum $filename_title.$ext"
            else
                set out_file "$target_dir/$filename_title.$ext"
            end

            if test $is_album -eq 1
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
            else
                ${getExe ffmpeg} -v error -y -i "$f" \
                    -c copy \
                    -metadata artist="$artist" \
                    -metadata title="$title_clean" \
                    -metadata description= \
                    -metadata synopsis= \
                    -metadata comment= \
                    "$out_file"
            end

            if test $status -eq 0
                rm -f "$f"
            else
                echo "    FAILED: $base_name"
            end
        end
        echo "Rename and Move completed!"

        # Remove the temp download dir
        # Guard: only ever remove paths under BASE_DIR.
        if string match -q "$BASE_DIR/*" -- "$tmp_dir"
            rm -rf "$tmp_dir"
        end
    end
  '';
}

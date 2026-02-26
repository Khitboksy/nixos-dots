{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with pkgs; {
  pf = ''
    fzf --bind ctrl-y:preview-up,ctrl-e:preview-down \
        --bind ctrl-b:preview-page-up,ctrl-f:preview-page-down \
        --bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down \
        --bind ctrl-k:up,ctrl-j:down \
        --preview='bat --style=numbers --color=always --line-range :100 {}'
  '';

  ff = ''
    for file in (pf)
        set cmd "v $file"
        echo $cmd
        eval $cmd
    end
  '';

  ytmp3 = ''
    ${getExe yt-dlp} \
        -x \
        --audio-format mp3 \
        --embed-metadata \
        --embed-thumbnail \
        --ignore-errors \
        --no-overwrites \
        --concurrent-fragments 8 \
        -o "%(playlist_index)02d.%(title)s.%(ext)s" \
        $argv
  '';

  ytv = ''
    ${getExe yt-dlp} \
        -f "bv*+ba/b" \
        --ignore-errors \
        --no-overwrites \
        --concurrent-fragments 8 \
        -o "%(playlist_index)02d.%(title)s.%(ext)s" \
        $argv
  '';

  ytbulk = ''
    echo "What type of download?"
    echo "1) music"
    echo "2) video"
    read -P "Enter choice (music/video): " media_type

    if test "$media_type" = "music"
        set BASE_DIR /mnt/nix-data/media/music
        set DOWNLOAD_CMD ytmp3
    else if test "$media_type" = "video"
        set BASE_DIR /mnt/nix-data/media/video
        set DOWNLOAD_CMD ytv
    else
        echo "Invalid choice. Please enter 'music' or 'video'."
        return 1
    end

    read -P "How many directories would you like to create? " dir_count

    if not string match -rq '^[0-9]+$' -- $dir_count
        echo "Please enter a valid number."
        return 1
    end

    set dirs
    set links

    for i in (seq 1 $dir_count)
        read -P "Name/path for directory $i (relative to $BASE_DIR): " dir_name
        set dirs $dirs $dir_name
    end

    for dir in $dirs
        read -P "Enter YouTube link for $dir: " link
        set links $links $link
    end

    echo ""
    echo "========== CONFIRMATION =========="
    echo "Media Type: $media_type"
    echo "Base Directory: $BASE_DIR"
    echo ""

    for i in (seq 1 (count $dirs))
        echo "Directory: $BASE_DIR/$dirs[$i]"
        echo "Link:      $links[$i]"
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

    for dir in $dirs
        mkdir -p "$BASE_DIR/$dir"; or begin
            echo "Failed creating $BASE_DIR/$dir"
            return 1
        end
    end

    for i in (seq 1 (count $dirs))
        set target_dir "$BASE_DIR/$dirs[$i]"
        set link "$links[$i]"

        echo "Downloading into $target_dir..."

        cd "$target_dir"; or begin
            echo "Failed to enter $target_dir - skipping"
            continue
        end

        $DOWNLOAD_CMD $link

        if test $status -ne 0
          echo "Warning: Some items failed in $link - ignored"
        end
    end

    echo ""
    echo "All downloads complete."
  '';
}

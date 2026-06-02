{
  pkgs,
  lib,
  ...
}:
with lib;
with pkgs;
{
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
    ${getExe yt-dlp}
        -f "bv*+ba/b"
        --ignore-errors
        --no-overwrites
        --concurrent-fragments 8
        -o "%(playlist_index)02d.%(title)s.%(ext)s"
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
  jupiter = ''
    opencode attach "http://localhost:4096" $argv
  '';

  # ── Nix build commands ────────────────────────────────────
  ns = ''
    nh os switch -- --cores 8 --max-jobs 1 $argv
    and echo "✓ switch complete"
  '';
  nsu = ''
    nh os switch --update -- --cores 12 --max-jobs 8 $argv
    and echo "✓ switch + update complete"
  '';
  nb = ''
    nh os boot -- --cores 8 --max-jobs 1 $argv
    and echo "✓ boot build complete"
  '';
  nbu = ''
    nh os boot --update -- --cores 12 --max-jobs 8 $argv
    and echo "✓ boot + update complete"
  '';
  nfu = ''
    nix flake update $argv
    and echo "✓ flake lockfile updated"
  '';
  nfc = ''
    nix flake check $argv 2>&1 \
      | grep -v '^warning:' \
      | grep -v '^The check omitted' \
      | grep -v "^Use '--all-systems'" \
      | grep -v '^\s*$'
    if test $pipestatus[1] -eq 0
      echo "✓ all checks passed"
    end
  '';
  mc-start = ''
    if test (count $argv) -eq 0
      echo "Usage: mc-start <server-name>"
      return 1
    end
    sudo systemctl start "minecraft-$argv[1]"
  '';

  mc-stop = ''
    if test (count $argv) -eq 0
      echo "Usage: mc-stop <server-name>"
      return 1
    end
    sudo systemctl stop "minecraft-$argv[1]" &
    echo "→ Stopping $argv[1] in background (may take a moment to save)..."
  '';

  mc-restart = ''
    if test (count $argv) -eq 0
      echo "Usage: mc-restart <server-name>"
      return 1
    end
    sudo systemctl restart "minecraft-$argv[1]" &
    echo "→ Restarting $argv[1] in background..."
  '';

  mc-status = ''
    if test (count $argv) -eq 0
      echo "Usage: mc-status <server-name>"
      return 1
    end
    systemctl status "minecraft-$argv[1]"
  '';

  mc-logs = ''
    if test (count $argv) -eq 0
      echo "Usage: mc-logs <server-name>"
      return 1
    end
    journalctl -u "minecraft-$argv[1]" -f
  '';

  mc-cmd = ''
    if test (count $argv) -lt 2
      echo "Usage: mc-cmd <server-name> <command...>"
      echo "  e.g. mc-cmd tekkit2 op friendname"
      echo "       mc-cmd tekkit2 say Restarting in 5 minutes"
      return 1
    end
    set server $argv[1]
    set cmd $argv[2..-1]
    set fifo "/var/lib/minecraft-$server/.stdin-fifo"
    if not test -p "$fifo"
      echo "Error: Server '$server' is not running (FIFO not found)"
      return 1
    end
    echo "$cmd" > "$fifo"
  '';

  mc-console = ''
    if test (count $argv) -eq 0
      echo "Usage: mc-console <server-name>"
      return 1
    end
    set server $argv[1]
    set fifo "/var/lib/minecraft-$server/.stdin-fifo"
    if not test -p "$fifo"
      echo "Error: Server '$server' is not running (start it with mc-start $server)"
      return 1
    end
    echo "⚡ Console for '$server'. Commands sent to server. Type 'exit' to quit."
    echo "   (Open another terminal and run 'mc-logs $server' to see output live.)"
    while true
      read -P "$server> " cmd
      if test "$cmd" = "exit"
        echo "Console closed."
        break
      end
      echo "$cmd" > "$fifo"
    end
  '';
}

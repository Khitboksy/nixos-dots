{
  pkgs,
  lib,
  ...
}:

with lib;
with lib.custom;
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
  give-terra = ''
        set -l usage "Usage: give-terra <source> <destination> [rsync flags...]

    Copy files from this machine to terra via rsync over SSH.
    Destination is relative to helios's home on terra unless absolute.

    Examples:
      give-terra ./Artist /srv/music/
      give-terra ~/videos/clip.mp4 /home/helios/videos/
      give-terra ./stuff /tmp/ -P --dry-run"

        if test (count $argv) -lt 2
            echo $usage
            return 1
        end

        set -l src $argv[1]
        set -l dst $argv[2]
        set -l opts $argv[3..-1]

        set -l abs_src (realpath $src 2>/dev/null; or echo $src)
        set -l rsync_opts -avz --progress --partial --human-readable

        if test (count $opts) -gt 0
            set rsync_opts $rsync_opts $opts
        end

        echo "helios -> terra: $abs_src -> $dst"
        rsync $rsync_opts "$abs_src" "helios@terra:$dst"

        if test $status -eq 0
            echo "Transfer complete."
        else
            echo "Transfer failed."
            return 1
        end
  '';

  __fish_git_abbr_expand = ''
    set -l tokens (commandline -op)
    set -l subcmd ""
    if test (count $tokens) -ge 2
      set subcmd $tokens[2]
    end

    switch "$subcmd"
      case add
        switch $argv[1]
          case a
            echo -A
          case '*'
            echo $argv[1]
        end
      case commit
        switch $argv[1]
          case a
            echo --amend
          case an
            echo --amend --no-edit
          case m
            echo -m
          case '*'
            echo $argv[1]
        end
      case push
        switch $argv[1]
          case m
            echo main
          case o
            echo origin
          case f
            echo --force-with-lease
          case ff
            echo --force
          case '*'
            echo $argv[1]
        end
      case pull
        switch $argv[1]
          case o
            echo origin
          case r
            echo --rebase
          case ff
            echo --ff-only
          case '*'
            echo $argv[1]
        end
      case rebase
        switch $argv[1]
          case i
            echo -i
          case c
            echo --continue
          case s
            echo --skip
          case a
            echo --abort
          case '*'
            echo $argv[1]
        end
      case switch
        switch $argv[1]
          case c
            echo -c
          case '*'
            echo $argv[1]
        end
      case branch
        switch $argv[1]
          case d
            echo --delete
          case D
            echo --delete --force
          case m
            echo --move
          case a
            echo --all
          case '*'
            echo $argv[1]
        end
      case checkout
        switch $argv[1]
          case b
            echo -b
          case B
            echo -B
          case '*'
            echo $argv[1]
        end
      case '*'
        echo $argv[1]
    end
  '';
  palette = import ./palette.nix;
}
// importDir ./mc-server { inherit pkgs lib; }

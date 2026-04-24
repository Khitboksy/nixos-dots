{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.shells.fish;
in
{
  options.shells.fish = with types; {
    enable = mkBoolOpt false "Enable Fish Configuration";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      generateCompletions = false;
      interactiveShellInit = ''
        set -gx LC_ALL en_US.UTF-8
        set -gx NH_FLAKE /home/helios/builds/
        set -g FZF_PREVIEW_FILE_CMD "head -n 10"
        set -g FZF_PREVIEW_DIR_CMD "ls"

        set -Ux MANROFFOPT '-c'
        set -Ux MANPAGER "sh -c 'col -bx | bat -l man -p'"

        # Remove default greeting
        set -g fish_greeting ""

        if not set -q TMUX
          # Start tmux, try to restore from continuum
          # Continuum restores highest available slot (prefer your hard saves over auto-saves)
          exec tmux -u new -s main
        end
      '';
      functions = import ../functions.nix { inherit pkgs lib config; } // {
        fish_prompt = {
          body = ''
            # Capture exit status FIRST, before any other commands
            set -l last_status $status

            # Colors from lib.custom.colors
            set -l c_dir (set_color "${colors.mauve.hex}")
            set -l c_clean (set_color "${colors.green.hex}")
            set -l c_dirty (set_color "${colors.yellow.hex}")
            set -l c_err (set_color "${colors.red.hex}")
            set -l c_reset (set_color normal)

            # Current directory (condensed with ~)
            set -l prompt_dir (prompt_pwd)

            # Git status
            set -l git_status ""
            if type -q git
                set -l git_branch (git symbolic-ref --short HEAD 2>/dev/null)
                if test -n "$git_branch"
                    set -l dirty (git status --porcelain 2>/dev/null | wc -l)
                    if test "$dirty" -gt "0"
                        set git_status " $c_dirty$git_branch$c_reset"
                    else
                        set git_status " $c_clean$git_branch$c_reset"
                    end
                end
            end

            # Error status
            set -l status_text ""
            if test $last_status -ne 0
                set status_text " $c_err$last_status$c_reset"
            end

            # Output prompt without newline
            printf "%s%s%s%s%s%s$c_clean ->$c_reset " "$c_reset" "$c_dir" "$prompt_dir" "$c_reset" "$git_status" "$status_text"
          '';
        };
      };
      shellAliases = import ../shellAliases.nix { inherit pkgs lib config; };
    };
    home.packages = with pkgs; [
      gnumake
      # Runs programs without installing them
      comma

      # grep replacement
      ripgrep

      # ping, but with cool graph
      gping

      fzf

      # dns client
      doggo

      # neofetch but for git repos
      onefetch

      # neofetch but for cpu's
      cpufetch

      # download from yt and other websites
      yt-dlp

      # man pages for tiktok attention span mfs
      tealdeer

      # markdown previewer
      glow

      # profiling tool
      hyperfine

      imagemagick
      ffmpeg-full

      # preview images in terminal
      catimg

      # networking stuff
      nmap
      wget

      # faster find
      fd

      # http request thingy
      xh

      # generate regex
      grex

      # json thingy
      jq

      # syncthnig for acoustic people
      rsync

      figlet
      # Generate qr codes
      qrencode

      unzip
    ];

  };
}

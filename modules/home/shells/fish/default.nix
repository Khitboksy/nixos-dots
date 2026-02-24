{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.shells.fish;
in {
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

        if not set -q TMUX
          tmux
        end
      '';

      plugins = [
        {
          name = "foreign-env";
          src = pkgs.fishPlugins.foreign-env.src;
        }
        {
          name = "fzf.fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
        {
          name = "z";
          src = pkgs.fishPlugins.z.src;
        }
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
        {
          name = "colored-man-pages";
          src = pkgs.fishPlugins.colored-man-pages.src;
        }
      ];

      functions = import ../funct.nix {inherit pkgs lib config;};

      shellAliases = import ../aliases.nix {inherit pkgs lib config;};
    };

    home.packages = with pkgs;
      [
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
      ]
      ++ (
        if !pkgs.stdenv.isDarwin
        then [
          hcxdumptool
          hashcat
        ]
        else []
      );
  };
}

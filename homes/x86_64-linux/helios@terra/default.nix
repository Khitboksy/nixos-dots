{
  pkgs,
  zenith,
  config,
  ...
}:

{

  apps = {

    tools = {
      neovim.enable = true;
      macchina.enable = true;
      noctalia = {
        enable = true;
        bar = "terra";
      };
    };

    term = {
      kitty.enable = true;
      tuis = {
        tmux.enable = true;
        yazi.enable = true;
        palette = {
          enable = true;
          default = {
            dir = "${config.home.homeDirectory}/gh/nd/zenith/lib/theme/colors";
            palette = "helios";
          };
          extraDirs = [
            # "${home}/repos/palette-tui/palettes"
          ];
          dirFormats = {
            "${config.home.homeDirectory}/gh/nd/zenith/lib/theme/colors" = [ "hex" ];
          };
        };
      };
    };

    helpers = {
      rofi.enable = true;
    };

    music = {
      rmpc = {
        enable = true;
        lyricsDir = "/srv/lyrics";
        lyricAuthor = true;
      };
      discord-rpc.enable = true;
      picard.enable = true;
    };

    ai = {
      modelMain = "opencode/mimo-v2.5-free";
      modelSub = "opencode/muse-spark-1.3-contributor-free";
      opencode.enable = true;
    };

    games = {
      burrow.enable = true;
    };

  };

  shells.fish.enable = true;

  wayland.windowManager.niri.enable = true;

  rice.gtk.enable = true;

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
    autoEnable = false;
  };

  programs = {
    gpg.enable = true;
    fzf.enable = true;

    btop = {
      enable = true;

      extraConfig = ''
        update_ms = 100
        vim_keys = true
      '';

      settings = {
        theme_background = false;
      };
    };
  };

  services = {
    wallpaper.paper = zenith.lib'.wallpapers.tftl-16;
    musicPlayerDaemon = {
      enable = true;
      musicDir = "/srv/music";
    };
  };

  home.packages = with pkgs; [
    wl-clipboard-rs
    custom.enc
    git
    signal-desktop
    bitwarden-cli
    firefox
    vesktop
    obsidian
  ];

  home.stateVersion = "26.05";
}

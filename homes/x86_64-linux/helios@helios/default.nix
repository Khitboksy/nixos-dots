{
  pkgs,
  lib,
  inputs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
in {
  apps = {
    tools = {
      neovim.enable = true;
      tmux.enable = true;
      lf.enable = true;
      cava.enable = true;
      dms.enable = true;
    };

    term = {
      kitty.enable = true;
    };

    helpers = {
      tofi.enable = true;
    };

    music = {
      rmpc.enable = true;
    };

    games = {
      mangohud = {
        enable = true;
        defaultProfile = "bare";
      };
    };
  };

  shells = {
    fish.enable = true;
  };

  wayland.windowManager.niri = {
    enable = true;
  };

  services = {
    wallpaper.enable = true;
    gpg-agent = {
      enable = true;
      pinentry = {
        package = lib.mkForce pkgs.pinentry-gnome3;
      };
      enableSshSupport = true;
      enableBashIntegration = true;
    };
    mpd = {
      enable = true;
      musicDirectory = "/mnt/nix-data/media/music/";
      network.listenAddress = "127.0.0.1";
      network.port = 6600;
      extraConfig = ''
        audio_output {
          type  "pulse"
          name  "PipeWire Output"
          format "44100:16:2"
        }
        audio_output {
          type   "fifo"
          name   "my_fifo"
          path   "/tmp/mpd.fifo"
          format "44100:16:2"
        }
      '';
    };
    mpdscribble = {
      enable = true;
      endpoints = {
        "last.fm" = {
          passwordFile = "/home/helios/secrets/lastfm.txt";
          username = "khitboksy";
        };
      };
    };
    opencode = {
      enable = true;
    };
  };

  rice.gtk.enable = true;

  catppuccin = {
    flavor = "mocha";
    accent = "sapphire";

    btop.enable = true;
    fzf.enable = true;
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

    obs-studio = {
      enable = true;
      package = pkgs.obs-studio.override {
        cudaSupport = true;
      };
    };
  };

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      "text/html" = "zen-browser.desktop";
      "x-scheme-handler/http" = "zen-browser.desktop";
      "x-scheme-handler/https" = "zen-browser.desktop";
      "x-scheme-handler/about" = "zen-browser.desktop";
      "x-scheme-handler/unknown" = "zen-browser.desktop";

      "inode/directory" = ["org.gnome.Nautilus.desktop"];

      "image/jpeg" = ["org.gnome.Loupe.desktop"];
      "image/png" = ["org.gnome.Loupe.desktop"];
      "image/gif" = ["org.gnome.Loupe.desktop"];
      "image/webp" = ["org.gnome.Loupe.desktop"];
      "image/tiff" = ["org.gnome.Loupe.desktop"];
      "image/bmp" = ["org.gnome.Loupe.desktop"];
      "image/x-icon" = ["org.gnome.Loupe.desktop"];
      "image/svg+xml" = ["org.gnome.Loupe.desktop"];
    };
  };

  dconf.settings = {
    "org/gnome/nautilus/preferences" = {
      "default-folder-viewer" = "list-view";
      "search-filter-time-type" = "last_modified";
    };
    "org/gnome/terminal/legacy/profiles:" = {
      "default" = "kitty";
    };
    "org/gnome/Loupe" = {
      "interpolation-quality" = "high";
      "zoom-gesture" = true;
    };
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  home.packages = with pkgs; [
    nautilus
    loupe
    networkmanagerapplet
    wl-clipboard-rs
    custom.enc
    #deadlock-mod-manager
    #element-desktop
    r2modman
    nix-tree
    tokei
    clonehero
    prismlauncher
    ckan
    qbittorrent
    libimobiledevice
    ifuse
    lf
    signal-desktop
    vesktop
    inputs.zen-browser.packages."${system}".default
    #inputs.osu-nixos.packages."${system}".osu-nixos
    git
    openrgb-with-all-plugins
    vlc
    tidal-hifi
    fastfetch
    btop
    mpd
    #osu-lazer
    inputs.mcp-nixos.packages.${system}.default
    ttfautohint
    nodejs
    bitwarden-desktop
    nh
  ];

  home.stateVersion = "24.11";
}
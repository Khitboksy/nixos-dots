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
    };

    term = {
      kitty.enable = true;
      ghostty.enable = true;
    };

    helpers = {
      rofi.enable = true;
      waybar.enable = false;
    };

    music = {
      rmpc.enable = true;
      cava.enable = true;
    };
  };

  shells.fish.enable = true;

  wms = {
    hyprland.enable = false;
    niri.enable = true;
  };

  rice.gtk.enable = true;

  catppuccin = {
    flavor = "mocha";
    accent = "sapphire";

    btop.enable = true;
    fuzzel.enable = true;
    kitty.enable = true;
    fzf.enable = true;
  };
  programs = {
    gpg.enable = true;

    fuzzel.enable = true;

    fzf.enable = true;

    btop = {
      enable = true;
      #catppuccin.enable = true;
      extraConfig = ''
        update_ms = 100
        vim_keys = true
      '';
      settings = {
        theme_background = false;
      };
    };

    dank-material-shell = {
      enable = true;

      niri.enableKeybinds = true;
      systemd.enable = true;

      enableVPN = true;
      enableCalendarEvents = true;
      enableDynamicTheming = true;
      enableSystemMonitoring = true;
      enableAudioWavelength = true;
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
      "interpolation-quality" = "high"; # Set image scaling quality
      "zoom-gesture" = true; # Enable zoom gesture
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
    wl-clipboard
    custom.enc
    deadlock-mod-manager
    element-desktop
    r2modman
    nix-tree
    tokei
    clonehero
    prismlauncher
    ckan # Comprehensive Kerbal Archive Network. KSP mod manager
    qbittorrent
    libimobiledevice
    ifuse
    lf
    signal-desktop
    vesktop
    tmux-sessionizer
    inputs.zen-browser.packages."${system}".default # beta
    git
    openrgb-with-all-plugins # RGB LED controller
    vlc
    cider-2
    fastfetch
    btop # better htop
    mpd
  ];
  services = {
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
    };
  };

  home.stateVersion = "24.11";
}

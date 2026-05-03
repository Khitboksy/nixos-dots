{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  # Custom Home-Manager Modules located in ../../../modules/home/*
  apps = {

    tools = {

      neovim.enable = true;
      tmux.enable = true;
      lf.enable = true;
      yazi.enable = true;
      cava.enable = true;

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
      mangohud.enable = true;
    };
  };

  shells = {
    fish.enable = true;
  };

  wayland.windowManager.niri = {
    enable = true;
  };

  services = {

    # Custom Home-Manager Services located in ../../../modules/home/services/*
    wallpaper.enable = true;
    opencode.enable = true;
    musicPlayerDaemon.enable = true;

    gpg-agent = {
      enable = true;
      pinentry = {
        package = lib.mkForce pkgs.pinentry-gnome3;
      };
      enableSshSupport = true;
      enableBashIntegration = true;
    };
  };

  rice.gtk.enable = true;

  # Standard home.nix configuration stuff

  catppuccin = {
    flavor = "mocha";
    accent = "mauve";
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

      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];

      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "image/gif" = [ "org.gnome.Loupe.desktop" ];
      "image/webp" = [ "org.gnome.Loupe.desktop" ];
      "image/tiff" = [ "org.gnome.Loupe.desktop" ];
      "image/bmp" = [ "org.gnome.Loupe.desktop" ];
      "image/x-icon" = [ "org.gnome.Loupe.desktop" ];
      "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
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
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  home.packages = with pkgs; [
    nautilus
    loupe
    wl-clipboard-rs
    custom.enc
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
    git
    vlc
    tidal-hifi
    fastfetch
    btop
    inputs.mcp-nixos.packages.${system}.default
    ttfautohint
    nodejs
    bitwarden-desktop
    nh

  ];

  home.stateVersion = "24.11";
}

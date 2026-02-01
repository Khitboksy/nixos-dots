{
  pkgs,
  lib,
  ...
}: {
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
  };
  shells.fish.enable = true;
  wms = {
    hyprland.enable = false;
    niri.enable = true;
  };
  rice.gtk.enable = true;
  catppuccin = {
    btop.enable = true;
    fuzzel.enable = true;
    kitty.enable = true;
    cava.enable = true;
  };
  programs = {
    gpg.enable = true;

    cava.enable = true;
    fuzzel.enable = true;
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
    dankMaterialShell = {
      enable = true;

      niri.enableKeybinds = true;
      systemd.enable = true;

      enableVPN = true;
      enableCalendarEvents = true;
      enableDynamicTheming = true;
      enableSystemMonitoring = true;
      enableAudioWavelength = true;
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

  home.packages = [
    pkgs.nautilus
    pkgs.loupe
    pkgs.networkmanagerapplet
    pkgs.wl-clipboard
    pkgs.custom.enc

    pkgs.deadlock-mod-manager

    pkgs.element-desktop

    pkgs.obs-studio
    pkgs.r2modman

    pkgs.nix-tree
    pkgs.tokei

    pkgs.clonehero

    pkgs.prismlauncher

    pkgs.ckan # Comprehensive Kerbal Archive Network. KSP mod manager

    pkgs.qbittorrent

    pkgs.libimobiledevice
    pkgs.ifuse

    pkgs.lf
  ];
  services = {
    gpg-agent = {
      enable = true;
      pinentryPackage = lib.mkForce pkgs.pinentry-gnome3;
      enableSshSupport = true;
      enableBashIntegration = true;
    };
  };

  home.stateVersion = "24.11";
}

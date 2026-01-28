{
  pkgs,
  lib,
  ...
}: {
  apps = {
    tools = {
      neovim.enable = true;
      tmux.enable = true;
    };

    term = {
      kitty.enable = true;
      ghostty.enable = true;
    };

    helpers = {
      rofi.enable = true;
      waybar.enable = true;
    };
  };
  shells.fish.enable = true;
  wms.hyprland.enable = true;
  rice.gtk.enable = true;
  catppuccin = {
    btop.enable = true;
    fuzzel.enable = true;
    kitty.enable = true;
  };
  programs = {
    gpg.enable = true;

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

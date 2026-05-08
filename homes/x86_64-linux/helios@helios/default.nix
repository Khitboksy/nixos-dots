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
      macchina.enable = true;
    };

    term = {
      kitty.enable = true;
      tuis = {
        tmux.enable = true;
        yazi.enable = true;
        cava.enable = true;
      };
    };

    helpers = {
      rofi.enable = true;
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
    };
  };

  dconf.settings = {
    "org/gnome/terminal/legacy/profiles:" = {
      "default" = "kitty";
    };
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  home.packages = with pkgs; [
    wl-clipboard-rs
    custom.enc
    qbittorrent
    libimobiledevice
    ifuse
    signal-desktop
    vesktop
    inputs.zen-browser.packages."${system}".default
    git
    btop
    inputs.mcp-nixos.packages.${system}.default
    ttfautohint
    nodejs
    bitwarden-desktop
    nh

  ];

  home.stateVersion = "24.11";
}

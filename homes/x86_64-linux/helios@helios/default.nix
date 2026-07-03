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

    ai.enable = true;

    tools = {
      neovim.enable = true;
      macchina.enable = true;
      dms.enable = false;
      noctalia = {
        enable = true;
        bar = "helios";
      };
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

    wallpaper.paper = lib.custom.wallpapers.tftl-23;

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

  rice = {
    gtk.enable = true;
    fonts = [ "Helios" ];
  };

  # Standard home.nix configuration stuff

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
    btop.enable = true;
    fzf.enable = true;
    autoEnable = false;
  };

  programs = {
    gpg.enable = true;
    fzf.enable = true;

    ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "terra" = {
          hostname = "terra";
          user = "helios";
          identityFile = "~/.ssh/id_ed25519_terra";
        };
      };
    };

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
      "text/html" = "zen.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "x-scheme-handler/about" = "zen.desktop";
      "x-scheme-handler/unknown" = "zen.desktop";
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
    ttfautohint
    nodejs
    bitwarden-cli
    nh
    obsidian

  ];

  home.stateVersion = "24.11";
}

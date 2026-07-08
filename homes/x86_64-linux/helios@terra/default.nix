{
  pkgs,
  lib,
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
      };
    };

    helpers = {
      rofi.enable = true;
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

  services.wallpaper.paper = lib.custom.wallpapers.tftf-11;

  home.packages = with pkgs; [
    wl-clipboard-rs
    git
    bitwarden-cli
    firefox
    vesktop
  ];

  home.stateVersion = "26.05";
}

{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.rice.gtk;
  ctp = config.catppuccin;
  gtkMocha = builtins.readFile ./themes/Helios/Helios.css;
in {
  options.rice.gtk = with types; {
    enable = mkBoolOpt false "Enable GTK Customization";
  };

  options.custom = {
    colors = mkOption {
      type = types.attrsOf types.attrs;
      internal = true;
      description = "Theme color definitions";
    };
  };

  config = mkIf cfg.enable {
    catppuccin.cursors.enable = true;

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;
      font = {
        name = "HeliosTerm";
        size = 12;
      };

      theme = {
        name = "Helios";
      };

      gtk3.extraCss = gtkMocha;
      gtk4.extraCss = gtkMocha;

      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.catppuccin-papirus-folders.override {
          accent = ctp.accent;
          flavor = ctp.flavor;
        };
      };

      gtk3.extraConfig = {
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintslight";
        gtk-xft-rgba = "rgb";
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk4.theme = null;
      gtk2.extraConfig = ''
        gtk-xft-antialias=1
        gtk-xft-hinting=1
        gtk-xft-hintstyle="hintslight"
        gtk-xft-rgba=rgb
      '';
    };

    home = {
      packages = with pkgs; [
        qt5.qttools
        qt6Packages.qtstyleplugin-kvantum
        libsForQt5.qtstyleplugin-kvantum
        libsForQt5.qt5ct
      ];
    };
  };
}

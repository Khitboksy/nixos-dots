{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.ui.fonts;
in
{
  options.ui.fonts = with types; {
    enable = mkBoolOpt false "Enable Custom Fonts";
  };

  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        noto-fonts-color-emoji
        iosevka
      ];

      enableDefaultPackages = false;

      fontconfig = {
        defaultFonts = {
          monospace = [
            "Iosevka"
            "Iosevka"
            "Noto Color Emoji"
          ];
          sansSerif = [
            "Iosevka"
            "Iosevka"
            "Noto Color Emoji"
          ];
          serif = [
            "Iosevka"
            "Iosevka"
            "Noto Color Emoji"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}

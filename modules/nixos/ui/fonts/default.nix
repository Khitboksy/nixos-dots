{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.ui.fonts;
in {
  options.ui.fonts = with types; {
    enable = mkBoolOpt false "Enable Custom Fonts";
  };

  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        noto-fonts-color-emoji
      ];

      enableDefaultPackages = false;

        fontconfig = {
          defaultFonts = {
            monospace = [
              "HeliosTerm"
              "Noto Color Emoji"
            ];
            sansSerif = [
              "HeliosProportional"
              "Noto Color Emoji"
            ];
            serif = [
              "HeliosProportional"
              "Noto Color Emoji"
            ];
            emoji = ["Noto Color Emoji"];
          };
        };
    };
  };
}

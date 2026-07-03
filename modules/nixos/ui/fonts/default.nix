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
        noto-fonts               # Broad script coverage (Arabic, Hebrew, Devanagari, etc.)
        noto-fonts-cjk-sans      # Chinese / Japanese / Korean
        noto-fonts-color-emoji   # Emoji
        iosevka
        jetbrains-mono
      ];

      enableDefaultPackages = false;

      fontconfig = {
        defaultFonts = {
          monospace = [
            "Iosevka"
            "JetBrains Mono"
            "Noto Sans Mono CJK SC"
            "Noto Color Emoji"
          ];
          sansSerif = [
            "Iosevka"
            "JetBrains Mono"
            "Noto Sans CJK SC"
            "Noto Color Emoji"
          ];
          serif = [
            "Iosevka"
            "JetBrains Mono"
            "Noto Serif CJK SC"
            "Noto Color Emoji"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}

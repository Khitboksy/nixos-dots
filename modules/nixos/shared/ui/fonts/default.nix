{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.shared.ui.fonts;
in
{
  options.shared.ui.fonts = with types; {
    enable = mkBoolOpt false "Enable Custom Fonts";
  };

  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        noto-fonts # Broad script coverage (Arabic, Hebrew, Devanagari, etc.)
        noto-fonts-cjk-sans # Chinese / Japanese / Korean
        noto-fonts-color-emoji # Emoji
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
          ];
          sansSerif = [
            "Iosevka"
            "JetBrains Mono"
            "Noto Sans CJK SC"
          ];
          serif = [
            "Iosevka"
            "JetBrains Mono"
            "Noto Serif CJK SC"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}

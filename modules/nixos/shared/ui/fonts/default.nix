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
        nerd-fonts.iosevka-term
        nerd-fonts.iosevka-term-slab
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
            "Iosevka Term Slab"
            "JetBrains Mono"
            "Noto Sans CJK SC"
          ];
          serif = [
            "Iosevka Term Slab"
            "JetBrains Mono"
            "Noto Serif CJK SC"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}

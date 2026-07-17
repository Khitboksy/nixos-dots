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
        # Workaround for fontconfig 2.18 genericfamily feature
        # which auto-classifies fonts and breaks font fallback order.
        # See: https://github.com/NixOS/nixpkgs/issues/541553
        localConf = ''
          <match target="pattern">
            <edit name="genericfamily" mode="delete"/>
          </match>
        '';
      };
    };
  };
}

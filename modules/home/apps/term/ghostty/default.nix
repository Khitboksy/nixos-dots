{
  config,
  lib,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.apps.term.ghostty;
in {
  options.apps.term.ghostty = with types; {
    enable = mkBoolOpt false "Enable Ghostty Term";
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;

      settings = {
        theme = "Catppuccin Mocha";

        font-family = "Iosevka Term";

        font-size = 14;

        font-style = "SemiBold";
        font-style-bold = "Bold";
        font-style-italic = "SemiBold Oblique";
        font-style-bold-italic = "Bold Oblique";

        gtk-single-instance = true;
        gtk-titlebar = false;

        alpha-blending = "linear-corrected";

        window-padding-x = 14;
        window-padding-y = 14;
        window-padding-balance = true;

        background-opacity = 0.8;
      };
    };
  };
}

{
  options,
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

        font-family = "Berkeley Mono";

        font-size = 14;

        font-style = "SemiBold ExtraCondensed";
        font-style-bold = "Bold ExtraCondensed";
        font-style-italic = "SemiBold ExtraCondensed Oblique";
        font-style-bold-italic = "Bold ExtraCondensed Oblique";

        gtk-single-instance = true;
        gtk-titlebar = false;

        alpha-blending = "linear-corrected";

        window-padding-x = 20;
        window-padding-y = 20;
        window-padding-balance = true;

        background-opacity = 0.8;
      };
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.apps.helpers.tofi;
in
{
  options.apps.helpers.tofi = with types; {
    enable = mkBoolOpt false "Enable Tofi";
  };

  config = mkIf cfg.enable {
    programs.tofi = {
      enable = true;
      package = pkgs.tofi;

      settings = {
        font = "Iosevka Bold";
        font-size = 32;
        hint-font = false;

        width = "26%";
        height = "30%";
        scale = false;
        margin-left = "37%";
        margin-top = "35%";

        background-color = colors.mantle.hex + "CC";

        border-width = 4;
        border-color = colors.sapphire.hex;
        outline-width = 0;
        corner-radius = 12;

        text-color = colors.blue.hex;
        prompt-color = colors.peach.hex;
        input-placeholder-color = colors.yellow.hex;

        selection-color = colors.peach.hex;
        selection-background = colors.surface0.hex + "00";
        selection-match-color = colors.green.hex;

        result-spacing = 2;
        padding-top = 0;
        padding-bottom = 0;
        padding-left = 8;
        padding-right = 0;
        margin = 0;

        drun-launch = true;
        hide-cursor = true;
        require-match = false;
        fuzzy-match = true;
      };
    };
  };
}

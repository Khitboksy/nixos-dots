{
  config,
  lib,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.apps.tools.cava;
in {
  options.apps.tools.cava = with types; {
    enable = mkBoolOpt false "Enable Cava Audio Visualizer";
  };

  config = mkIf cfg.enable {
    programs.cava = {
      enable = true;
      settings = {
        general.framerate = 165;
        color = {
          gradient = 1;
          gradient_color_1 = "${colors.teal.hex}";
          gradient_color_2 = "${colors.sky.hex}";
          gradient_color_3 = "${colors.sapphire.hex}";
          gradient_color_4 = "${colors.blue.hex}";
          gradient_color_5 = "${colors.mauve.hex}";
          gradient_color_6 = "${colors.pink.hex}";
          gradient_color_7 = "${colors.maroon.hex}";
          gradient_color_8 = "${colors.red.hex}";
        };
      };
    };
  };
}


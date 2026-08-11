{
  config,
  lib,
  zenith,
  ...
}:
with zenith.lib';
let
  cfg = config.apps.term.tuis.cava;
in
{
  options.apps.term.tuis.cava = with lib.types; {
    enable = mkBoolOpt false "Enable Cava Audio Visualizer";
  };

  config = lib.mkIf cfg.enable {
    programs.cava = {
      enable = true;
      settings = {
        general.framerate = 165;
        color = {
          gradient = 1;
          gradient_color_1 = "'${colors.helios.teal.hex}'";
          gradient_color_2 = "'${colors.helios.sky.hex}'";
          gradient_color_3 = "'${colors.helios.sapphire.hex}'";
          gradient_color_4 = "'${colors.helios.blue.hex}'";
          gradient_color_5 = "'${colors.helios.mauve.hex}'";
          gradient_color_6 = "'${colors.helios.pink.hex}'";
          gradient_color_7 = "'${colors.helios.maroon.hex}'";
          gradient_color_8 = "'${colors.helios.red.hex}'";
        };
      };
    };
  };
}

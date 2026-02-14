{
  config,
  lib,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.apps.music.cava;
in {
  options.apps.music.cava = with types; {
    enable = mkBoolOpt false "Enable Cava Audio Visualizer";
  };

  config = mkIf cfg.enable {
    /*
    xdg.configFile = {
      "cava/themes" = {
        enable = true;
        source = ./themes;
        recursive = true;
      };
    };
    */
    programs.cava = {
      enable = true;
      settings = {
        general.framerate = 165;
        color = {
          gradient = 1;
          gradient_color_1 = "'#94e2d5'";
          gradient_color_2 = "'#89dceb'";
          gradient_color_3 = "'#74c7ec'";
          gradient_color_4 = "'#89b4fa'";
          gradient_color_5 = "'#cba6f7'";
          gradient_color_6 = "'#f5c2e7'";
          gradient_color_7 = "'#eba0ac'";
          gradient_color_8 = "'#f38ba8'";
        };
      };
    };
  };
}

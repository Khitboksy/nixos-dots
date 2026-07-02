{
  config,
  lib,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.apps.tools.noctalia;
in
{
  options.apps.tools.noctalia = with types; {
    enable = mkBoolOpt false "Enable Noctalia Shell";
    bar = mkOption {
      type = types.enum [
        "helios"
        "terra"
      ];
      default = "helios";
      description = "Which bar layout to use. 'helios' for the desktop, 'terra' for the laptop.";
    };
  };

  config = mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      settings =
        (importDir ./config/settings { inherit lib; })
        // (import ./config/bar.nix) {
          barName = cfg.bar;
        };
      customPalettes = (import ./config/palette.nix) { inherit lib; };
    };

    # Launch Noctalia when niri starts
    wayland.windowManager.niri.settings = {
      spawn-at-startup = [
        [ "noctalia" ]
      ];
      binds = import ./config/binds.nix;
    };
  };
}

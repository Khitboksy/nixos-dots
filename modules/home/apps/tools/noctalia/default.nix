{
  config,
  lib,
  zenith,
  pkgs,
  ...
}:
with zenith.lib';
let
  cfg = config.apps.tools.noctalia;
in
{
  options.apps.tools.noctalia = with lib.types; {
    enable = mkBoolOpt false "Enable Noctalia Shell";
    bar = mkEnumOpt' [
      # Pick One
      "helios"
      "terra"
    ] "helios";
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      settings =
        (importDir ./config/settings { inherit lib; })
        // (import ./config/bar.nix) {
          barName = cfg.bar;
        };
      customPalettes = (import ./config/palette.nix) { inherit zenith; };
    };

    # Launch Noctalia when niri starts
    wayland.windowManager.niri.settings = {
      spawn-at-startup = [
        [ "noctalia" ]
      ];
      binds = import ./config/binds.nix;
    };

    home.packages = with pkgs; [
      ddcutil
    ];
  };
}

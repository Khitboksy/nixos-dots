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
  };

  config = mkIf cfg.enable {
    programs.noctalia = {
      enable = true;
      settings = (import ./settings.nix) { inherit lib; };
      customPalettes = (import ./palette.nix) { inherit lib; };
    };

    # Launch Noctalia when niri starts
    wayland.windowManager.niri.settings.spawn-at-startup = [
      [ "noctalia" ]
    ];
  };
}

{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.services.wallpaper;
in
{
  options.services.wallpaper = with types; {
    enable = mkBoolOpt false "Enable wallpaper with swaybg via niri spawn-at-startup";
  };

  config = mkIf cfg.enable {
    wayland.windowManager.niri.settings.spawn-at-startup = [
      [
        "${getExe pkgs.swaybg}"
        "-i"
        "${wallpaper}"
      ]
    ];
  };
}

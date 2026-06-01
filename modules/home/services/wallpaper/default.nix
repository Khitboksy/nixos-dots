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
  theme = import ../../../../lib/theme/default.nix { inherit lib; };
in
{
  options.services.wallpaper = with types; {
    enable = mkBoolOpt false "Enable wallpaper service with swaybg";
  };

  config = mkIf cfg.enable {
    systemd.user.services = {
      swaybg = mkGraphicalService {
        Unit.Description = "Wallpaper Chooser";
        Service = {
          ExecStart = "${getExe pkgs.swaybg} -i ${theme.wallpaper}";
          Restart = "always";
        };
      };
    };
  };
}

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
    enable = mkBoolOpt false "Enable Wallpaper via Niri";
    paper = mkPathOpt wallpapers.wall4 "Set Default Wallpaper";
  };

  config = mkIf cfg.enable {
    systemd.user.services.swaybg = {
      Unit = {
        Description = "Wallpaper Daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${getExe pkgs.swaybg} -i ${cfg.paper}";
        Restart = "on-failure";
        RestartSec = 1;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}

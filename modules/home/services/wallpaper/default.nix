{
  lib,
  zenith,
  config,
  pkgs,
  ...
}:
with zenith.lib';
let
  cfg = config.services.wallpaper;
in
{
  options.services.wallpaper = with lib.types; {
    enable = mkBoolOpt false "Enable Wallpaper via Niri";
    paper = mkPathOpt null "Set Default Wallpaper";
  };

  config = lib.mkIf cfg.enable {
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

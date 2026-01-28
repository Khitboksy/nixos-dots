{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.services.wallpaper;

  mkService = recursiveUpdate {
    Unit.PartOf = ["graphical-session.target"];
    Unit.After = ["graphical-session.target"];
    Install.WantedBy = ["graphical-session.target"];
  };
in {
  options.services.wallpaper = with types; {
    enable = mkBoolOpt false "Enable MPD (Music Player Daemon)";
  };

  config = mkIf cfg.enable {
    systemd.user.services = {
      swaybg = mkService {
        Unit.Description = "Wallpaper Chooser";
        Service = {
          ExecStart = "${getExe pkgs.swaybg} -i ${wallpaper}";
          Restart = "always";
        };
      };
    };
  };
}

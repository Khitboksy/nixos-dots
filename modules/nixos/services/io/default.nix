{
  lib,
  zenith,
  pkgs,
  config,
  ...
}:

with zenith.lib';

let
  cfg = config.services.io;
in

{
  options.services.io = with lib.types; {
    enable = mkBoolOpt false "Enable YeetMouse Mouse Acceleration";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      piper
      libratbag
    ];

    hardware.yeetmouse = {
      enable = false;
      sensitivity = 1.0;

      mode.jump = {
        acceleration = 1.3;
        midpoint = 5.0;
        smoothness = 0.3;
        useSmoothing = true;
      };

    };

    systemd.services = {

      ratbagd = {
        enable = true;
        description = "Daemon for configuring gaming mice (used by Piper)";
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${pkgs.libratbag}/bin/ratbagd";
          Restart = "on-failure";
        };
      };

    };

  };
}

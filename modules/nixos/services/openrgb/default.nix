{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.services.openrgb;
in

{
  options.services.openrgb = with types; {
    enable = mkBoolOpt false "Enable OpenRGB Server SDK";
    profileFile = mkPathOpt ./config/Helios.orp "Profile Used by openrgb.service";
    configFile = mkPathOpt ./config/OpenRGB.json "Config Used by OpenRGB Server SDK";
  };

  config = mkIf cfg.enable {

    environment = {
      systemPackages = [
        pkgs.openrgb
        pkgs.openrgb-with-all-plugins
      ];
    };

    services.hardware.openrgb.enable = true;

    systemd.services.openrgb = lib.mkForce {
      description = "OpenRGB headless server with profile";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.openrgb}/bin/openrgb --server --profile ${toString cfg.profileFile}";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };
  };
}

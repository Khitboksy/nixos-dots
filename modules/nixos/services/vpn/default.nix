{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.services.vpn;
in

{

  options.services.vpn = with types; {
    enable = mkBoolOpt false "Enable Mullvad-VPN";
  };

  config = mkIf cfg.enable {

    services.mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    systemd.services.mullvad-auto-connect = {
      description = "Mullvad VPN auto-connect";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = [
          "${pkgs.mullvad}/bin/mullvad connect"
        ];
      };
    };

  };
}

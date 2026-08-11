{
  lib,
  zenith,
  pkgs,
  config,
  ...
}:

with zenith.lib';

let
  cfg = config.shared.services.vpn;
in

{

  options.shared.services.vpn = with lib.types; {
    enable = mkBoolOpt false "Enable Mullvad-VPN";
  };

  config = lib.mkIf cfg.enable {

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

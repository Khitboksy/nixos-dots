{
  lib,
  zenith,
  config,
  ...
}:

with zenith.lib';

let
  cfg = config.shared.services.ssh;
in

{
  options.shared.services.ssh = with lib.types; {
    enable = mkBoolOpt false "Enable OpenSSH";
  };

  config = lib.mkIf cfg.enable {

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    networking.firewall.allowedTCPPorts = [ 22 ];

  };
}

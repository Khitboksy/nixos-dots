{
  lib,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.shared.services.ssh;
in

{
  options.shared.services.ssh = with types; {
    enable = mkBoolOpt false "Enable OpenSSH";
  };

  config = mkIf cfg.enable {

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

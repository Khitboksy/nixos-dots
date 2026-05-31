{
  lib,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.services.ssh;
in

{
  options.services.ssh = with types; {
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
  };
}

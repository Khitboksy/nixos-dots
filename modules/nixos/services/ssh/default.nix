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
    enable = mkBoolOpt true "Enable OpenSSH";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        passwordAuthentication = true;
        permitRootLogin = "no";
      };
    };
  };
}

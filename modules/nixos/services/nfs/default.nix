{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.services.nfs;
in

{
  options.services.nfs = with types; {
    enable = mkBoolOpt false "Enable NFS Server";
  };

  config = mkIf cfg.enable {
    services.nfs.server = {
      enable = true;
      exports = ''
        /home/helios/shared/opencode
        192.168.1.218(rw,sync,no_subtree_check,no_root_squash)
      '';
    };
  };
}

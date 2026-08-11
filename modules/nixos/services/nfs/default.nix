{
  lib,
  zenith,
  config,
  pkgs,
  ...
}:

with zenith.lib';

let
  cfg = config.services.nfs;
in

{
  options.services.nfs = {
    enable = mkBoolOpt false "Enable NFS Server";

    exports = mkStringListOpt [ ] ''
      List of NFS export entries. Each entry is a complete export line
      as it would appear in /etc/exports, e.g.:
        "/path/to/dir 10.0.0.1(rw,sync,no_subtree_check)"
    '';
  };

  config = lib.mkIf cfg.enable {

    services.rpcbind.enable = true;

    services.nfs.server = {
      enable = true;
      exports = lib.concatStringsSep "\n" cfg.exports;
    };

    networking.firewall.allowedTCPPorts = [
      111
      2049
    ];

  };
}

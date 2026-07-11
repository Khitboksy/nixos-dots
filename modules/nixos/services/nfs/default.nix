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
  options.services.nfs = {
    enable = mkBoolOpt false "Enable NFS Server";

    exports = mkStringListOpt [ ] ''
      List of NFS export entries. Each entry is a complete export line
      as it would appear in /etc/exports, e.g.:
        "/path/to/dir 10.0.0.1(rw,sync,no_subtree_check)"
    '';
  };

  config = mkIf cfg.enable {
    services.nfs.server = {
      enable = true;
      exports = lib.concatStringsSep "\n" cfg.exports;
    };
  };
}

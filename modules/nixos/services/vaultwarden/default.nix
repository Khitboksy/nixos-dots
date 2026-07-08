{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.vaultwarden;
in

{
  options.vaultwarden = with types; {
    enable = mkBoolOpt false "Enable Vaultwarden (Bitwarden-compatible password manager)";

    domain = mkStringOpt "http://terra:8222" "The URL clients use to reach the server";

    backupDir = mkOpt (nullOr types.str) null "Directory for automated database backups (SQLite only)";

    signupsAllowed = mkBoolOpt false "Allow anyone to register an account";

    invitationsAllowed = mkBoolOpt true "Allow existing users to invite new users";

    adminTokenFile =
      mkOpt (nullOr types.str) null
        "Path to file containing ADMIN_TOKEN=<hash> for admin panel access";
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";
      backupDir = cfg.backupDir;
      config = {
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = 8222;
        DOMAIN = cfg.domain;
        ENABLE_WEBSOCKET = true;
        SIGNUPS_ALLOWED = cfg.signupsAllowed;
        INVITATIONS_ALLOWED = cfg.invitationsAllowed;
      };
      environmentFile = lib.optional (cfg.adminTokenFile != null) cfg.adminTokenFile;
    };

    networking.firewall.allowedTCPPorts = [ 8222 ];
  };
}

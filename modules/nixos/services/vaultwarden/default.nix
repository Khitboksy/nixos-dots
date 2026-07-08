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

    domain = mkStringOpt "https://terra.tailnet-name.ts.net" "HTTPS URL clients use to reach the server. Update this to your actual tailnet name after running 'tailscale serve'";

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
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        DOMAIN = cfg.domain;
        ENABLE_WEBSOCKET = true;
        SIGNUPS_ALLOWED = cfg.signupsAllowed;
        INVITATIONS_ALLOWED = cfg.invitationsAllowed;
      };
      environmentFile = lib.optional (cfg.adminTokenFile != null) cfg.adminTokenFile;
    };
  };
}

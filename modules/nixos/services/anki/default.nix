{
  lib,
  zenith,
  config,
  pkgs,
  ...
}:

with zenith.lib';

let
  cfg = config.services.anki;
in

{

  options.services.anki = with lib.types; {
    enable = mkBoolOpt false "Enable Anki Flashcards";
    syncServer = mkBoolOpt false "Enables local Sync Server";
    openFirewall = mkBoolOpt false "Enables firewall for local Sync Server";
    username = mkStringOpt "username" "Username for local Sync Server";
    password = mkStringOpt "password" "Password for local Sync Server";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ pkgs.anki ];

    services.anki-sync-server = {
      enable = cfg.syncServer;
      address = "0.0.0.0";
      openFirewall = cfg.openFirewall;
      users = [
        {
          username = cfg.username;
          passwordFile = cfg.password;
        }
      ];
    };

  };

}

{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.gaming.apps.steam;
  wrappers = importDir ./wrappers { inherit pkgs; };
in

{
  options.gaming.apps.steam = with types; {
    enable = mkBoolOpt false "Enable Steam";
  };

  config = mkIf cfg.enable {

    programs.steam = {

      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-cachyos-x86_64-v3 ];

      config = {
        enable = true;
        defaultCompatTool = "Proton-Experimental";
        onSteamRunning = "close";
        apps = importDir ./gameProfiles {
          inherit
            gamemode
            mangohud
            lib
            wrappers
            ;
        };
      };
    };

    environment.variables = {
      PROTON_ENABLE_WAYLAND = "1";
    };
  };
}

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
      extraCompatPackages = [ pkgs.cachy-proton-v3 ];

      config = {
        enable = true;
        defaultCompatTool = "Proton-Experimental";
        onSteamRunning = "close";
        apps =
          let
            wrappers = importDir ./wrappers { inherit writeShellScriptBin; };
          in
          importDir ./gameProfiles {
            inherit wrappers;
            inherit (pkgs)
              gamemode
              mangohud
              lib

              ;
          };
      };
    };

    environment.variables = {
      PROTON_ENABLE_WAYLAND = "1";
    };
  };
}

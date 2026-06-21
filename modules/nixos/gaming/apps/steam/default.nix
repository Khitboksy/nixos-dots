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

      config = {
        enable = true;
        defaultCompatTool = "Proton-Experimental";
        closeSteam = true;
        apps = importDir ./gameProfiles { inherit pkgs lib wrappers; };
      };
    };

    environment.variables = {
      PROTON_ENABLE_WAYLAND = "1";
    };
  };
}

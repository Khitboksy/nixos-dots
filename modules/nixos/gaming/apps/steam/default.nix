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

      config = {
        enable = true;
        defaultCompatTool = "Proton-Experimental";
        closeSteam = true;
        apps = {

          deadlock = (import ./gameProfiles/deadlock.nix) { inherit pkgs lib; };
          overwatch = (import ./gameProfiles/overwatch.nix) { inherit pkgs lib; };
          kerbal = (import ./gameProfiles/kerbal.nix) { inherit pkgs lib; };

        };
      };
    };

    environment.variables = {
      PROTON_ENABLE_WAYLAND = "1";
    };
  };
}

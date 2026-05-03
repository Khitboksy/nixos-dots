{
  pkgs,
  lib,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.apps.steam;
in

{
  options.apps.steam = with types; {
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

          deadlock = (import ./apps/deadlock.nix) { inherit pkgs lib; };
          overwatch = (import ./apps/overwatch.nix) { inherit pkgs lib; };
          kerbal = (import ./apps/kerbal.nix) { inherit pkgs lib; };

        };
      };
    };

    environment = {
      variables = {
        PROTON_ENABLE_WAYLAND = "1";
      };
      systemPackages = [
        pkgs.protonup-qt
      ];
    };
  };
}

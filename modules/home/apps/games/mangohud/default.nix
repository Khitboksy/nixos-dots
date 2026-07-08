{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.custom;

let

  cfg = config.apps.games.mangohud;

in

{

  options.apps.games.mangohud = {
    enable = mkBoolOpt false "Enable MangoHud";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      mangohud
    ];

    xdg.configFile = {

      "MangoHud/MangoHud.conf" = {
        text = (import ./profiles/trans.nix) { inherit lib config; };
      };

      "MangoHud/fps.conf" = {
        text = (import ./profiles/fps.nix) { inherit lib config; };
      };

      "MangoHud/testing.conf" = {
        text = (import ./profiles/testing.nix) { inherit lib config; };
      };
    };
  };
}

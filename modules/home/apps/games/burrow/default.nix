{
  config,
  lib,
  zenith,
  pkgs,
  ...
}:

with zenith.lib';

let

  cfg = config.apps.games.burrow;

in

{

  options.apps.games.burrow = {
    enable = mkBoolOpt false "Enable the Burrow (Animal Jam Classic private server) client";
  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      custom.burrow
    ];

  };
}

{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
with lib.custom;
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  config = mkIf config.wayland.windowManager.niri.enable {

    wayland.windowManager.niri = {

      package = mkDefault inputs.niri-src.packages.${system}.niri;

      settings = importDir ./config { inherit lib; };

    };

    apps.tools.dms.enable = true;

    services.wallpaper.enable = true;
  };
}

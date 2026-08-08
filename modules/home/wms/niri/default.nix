{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom;
{
  config = mkIf config.wayland.windowManager.niri.enable {

    wayland.windowManager.niri = {

      package = mkDefault pkgs.niri;

      settings = importDir ./config { inherit lib; };

    };

    services.wallpaper.enable = true;

    home.packages = builtins.attrValues (importDir ./scripts { inherit pkgs; });
  };
}

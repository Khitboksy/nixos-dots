{
  config,
  lib,
  zenith,
  pkgs,
  ...
}:
with zenith.lib';
{
  config = lib.mkIf config.wayland.windowManager.niri.enable {

    wayland.windowManager.niri = {

      package = lib.mkDefault pkgs.niri;

      settings = importDir ./config { inherit lib; };

    };

    services.wallpaper.enable = true;

    home.packages = builtins.lib.attrValues (importDir ./scripts { inherit pkgs; });
  };
}

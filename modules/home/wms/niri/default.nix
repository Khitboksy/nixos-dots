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

      settings = importDir ./config { inherit zenith; };

    };

    services.wallpaper.enable = true;

    home.packages = builtins.attrValues (importDir ./scripts { inherit pkgs lib; });
  };
}

{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  config = lib.mkIf config.wayland.windowManager.niri.enable {
    wayland.windowManager.niri = {
      package = lib.mkDefault inputs.niri-src.packages.${system}.niri;
      settings =
        (import ./config/io.nix)
        // (import ./config/layout.nix { inherit lib; })
        // (import ./config/rules.nix)
        // {
          binds = import ./config/binds.nix;
        };
    };

    apps.tools.dms.enable = true;

    services.wallpaper.enable = true;
  };
}

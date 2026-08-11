{
  config,
  lib,
  zenith,
  ...
}:
with zenith.lib';
let
  cfg = config.apps.tools.dms;
in
{
  options.apps.tools.dms = with lib.types; {
    enable = mkBoolOpt false "Enable DMS (DankMaterialShell)";
  };

  config = lib.mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;
      systemd.enable = true;
      enableDynamicTheming = false;
      enableSystemMonitoring = true;
      enableVPN = true;
      enableAudioWavelength = true;
      settings = (import ./settings.nix) { inherit colors; };
    };
    wayland.windowManager.niri.settings = {
      binds = import ./binds.nix;
    };
  };
}

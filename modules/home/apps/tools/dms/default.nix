{
  config,
  lib,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.apps.tools.dms;
in
{
  options.apps.tools.dms = with types; {
    enable = mkBoolOpt false "Enable DMS (DankMaterialShell)";
  };

  config = mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;
      systemd.enable = true;
      enableDynamicTheming = false;
      enableSystemMonitoring = true;
      enableVPN = true;
      enableAudioWavelength = true;
      settings = (import ./settings.nix) { inherit colors; };
    };
  };
}

{
  pkgs,
  ...
}:

{
  deadlock = {
    id = 1422450;
    compatTool = "GE-Proton10-29";
    launchOptions = {

      env = {
        PROTON_USE_NTSYNC = true;
        DXVK_STATE_CACHE = "1";
      };

      wrappers = [
        #"/home/helios/.local/bin/mangohud-def"
        pkgs.mangohud
        pkgs.gamemode
      ];

      args = [
        "-novid"
        "-nojoy"
        "-novsync"
        "+exec autoexec.cfg"
        "-no_prewarm_map"
      ];
    };
  };
}

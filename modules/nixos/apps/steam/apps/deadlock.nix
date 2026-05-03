{
  pkgs,
  lib,
  ...
}:

{

  id = 1422450;
  compatTool = "GE-Proton10-29";

  launchOptions = {

    env = {
      PROTON_USE_NTSYNC = true;
      DXVK_ASYNC = "1";
    };

    args = [
      "-novid"
      "-nojoy"
      "-novsync"
      "+exec autoexec.cfg"
      "-no_prewarm_map"
    ];

    wrappers = [
      #"/home/helios/.local/bin/mangohud-def"
      (lib.getExe pkgs.mangohud)
      "gamescope -r 165 -w 1366 -h 768 --force-grab-cursor --"
    ];

  };

}

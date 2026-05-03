{
  pkgs,
  ...
}:

{

  id = 220200;
  compatTool = "Proton-Experimental";

  launchOptions = {

    env = {
      PROTON_USE_NTSYNC = true;
      DXVK_ASYNC = "1";
    };

    wrappers = [
      pkgs.gamemode
      pkgs.mangohud
      "gamescope -W 1366 -H 768 -w 1366 -h 768 -r 60 -f --rt --expose-wayland --adaptive-sync --force-grab-cursor --"
    ];

    args = [ "" ];

  };

}

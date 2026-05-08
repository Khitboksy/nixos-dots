{
  pkgs,
  ...
}:

{

  id = 2357570;
  compatTool = "GE-Proton10-29";

  launchOptions = {

    env = {
      SDL_VIDEODRIVER = "x11";
      PROTON_USE_NTSYNC = true;
    };

    wrappers = [
      pkgs.gamemode
      pkgs.mangohud
      "gamescope -r 165 -w 1366 -h 768 --force-grab-cursor --"
    ];

    args = [ "" ];

  };

}

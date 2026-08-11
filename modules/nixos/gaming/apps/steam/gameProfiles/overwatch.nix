{
  pkgs,
  ...
}:

{
  overwatch = {
    id = 2357570;
    compatTool = "proton-cachyos-x86_64-v3";

    env = {
      SDL_VIDEODRIVER = "x11";
      PROTON_USE_NTSYNC = true;
    };

    wrappers = [
      pkgs.gamemode
      pkgs.mangohud
      "gamescope -r 165 -w 1366 -h 768 --force-grab-cursor --"
    ];

    args = [ ];
  };
}

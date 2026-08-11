{
  gamemode,
  mangohud,
  ...
}:

{
  kerbal = {
    id = 220200;
    compatTool = "proton-cachyos-x86_64-v3";

    env = {
      PROTON_USE_NTSYNC = true;
      DXVK_STATE_CACHE = "1";
    };

    wrappers = [
      gamemode
      mangohud
      "gamescope -W 1366 -H 768 -w 1366 -h 768 -r 60 -f --rt --expose-wayland --adaptive-sync --force-grab-cursor --"
    ];

    args = [ ];
  };
}

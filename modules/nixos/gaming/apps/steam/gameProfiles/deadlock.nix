{
  mangohud,
  gamemode,

  ...
}:

{
  deadlock = {
    id = 1422450;
    compatTool = "proton-cachyos-x86_64-v3";

    env = {
      PROTON_USE_NTSYNC = true;
      DXVK_STATE_CACHE = "1";
    };

    wrappers = [
      #"/home/helios/.local/bin/mangohud-def"
      mangohud
      #gamemode
    ];

    args = [
      "-novid"
      "-nojoy"
      "-novsync"
      "+exec autoexec.cfg"
      "-no_prewarm_map"
    ];
  };
}

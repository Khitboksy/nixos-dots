{
  mangohud,
  #gamemode,

  ...
}:

{
  deadlock = {
    id = 1422450;
    compatTool = "proton-cachyos-x86_64-v3";

    env = {
      PROTON_USE_NTSYNC = true;
      PROTON_LOCAL_SHADER_CACHE = "1";
      DXVK_STATE_CACHE = "1";
      PROTON_DXVK_SAREK = "0";
    };

    wrappers = [
      mangohud
      #gamemode
    ];

    args = [
      "-novid"
      "-nojoy"
      "-novsync"
      "+exec autoexec.cfg"
      "-no_prewarm_map"
      "-vulkan"
      "-high"
    ];
  };
}

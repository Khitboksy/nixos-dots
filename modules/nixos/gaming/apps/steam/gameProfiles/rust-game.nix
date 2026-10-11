{
  lib,
  wrappers,
  ...
}:

{
  "252490" = {
    name = "rust-game";
    compatTool = "GE-Proton10-29";

    env = {
      PROTON_USE_NTSYNC = true;
      DXVK_STATE_CACHE = "1";
      vblank_mode = "0";
    };

    wrappers = [
      (lib.getExe wrappers.rust-eac-bypass)
    ];

    args = [
      "-window-mode exclusive"
      "-high"
    ];
  };
}

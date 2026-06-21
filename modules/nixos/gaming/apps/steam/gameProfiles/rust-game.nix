{
  lib,
  wrappers,
  ...
}:

{
  rust-game = {
    id = 252490;
    compatTool = "GE-Proton10-29";
    launchOptions = {

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
  };
}

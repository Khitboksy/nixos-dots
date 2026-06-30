{
  lib,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.hardware.swap;
in

{

  options.hardware.swap = with types; {
    enable = mkBoolOpt false "Enable Swap";
  };

  config = mkIf cfg.enable {
    zramSwap = {
      enable = true;
      memoryPercent = 50;
      algorithm = "zstd";
      priority = 100;
    };
  };
}

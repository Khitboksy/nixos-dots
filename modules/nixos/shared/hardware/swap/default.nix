{
  lib,
  zenith,
  config,
  ...
}:

with zenith.lib';

let
  cfg = config.shared.hardware.swap;
in

{

  options.shared.hardware.swap = with lib.types; {
    enable = mkBoolOpt false "Enable Swap";
  };

  config = lib.mkIf cfg.enable {
    zramSwap = {
      enable = true;
      memoryPercent = 50;
      algorithm = "zstd";
      priority = 100;
    };
  };
}

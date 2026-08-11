{
  lib,
  zenith,
  config,
  ...
}:

with zenith.lib';

let
  cfg = config.hardware.systems.terra;
in

{
  options.hardware.systems.terra = with lib.types; {
    enable = mkBoolOpt false "Enable Terra Hardware Modules";
  };

  config = lib.mkIf cfg.enable {

    hardware = {
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };
}

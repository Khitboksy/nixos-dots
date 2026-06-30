{
  lib,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.hardware.systems.terra;
in

{
  options.hardware.systems.terra = with types; {
    enable = mkBoolOpt false "Enable Terra Hardware Modules";
  };

  config = mkIf cfg.enable {

    hardware = {
      cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };
}

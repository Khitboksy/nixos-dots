{
  lib,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.hardware.systems.helios;
in

{
  options.hardware.systems.helios = with types; {
    enable = mkBoolOpt false "Enable Helios Hardware Modules";
  };

  config = mkIf cfg.enable {

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware = {

      cpu.amd.updateMicrocode = mkDefault true;

      nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = true;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      graphics = {
        enable = true;
        enable32Bit = true;
      };

    };
  };
}

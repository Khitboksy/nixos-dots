{
  lib,
  zenith,
  config,
  ...
}:

with zenith.lib';

let
  cfg = config.hardware.systems.helios;
in

{
  options.hardware.systems.helios = with lib.types; {
    enable = mkBoolOpt false "Enable Helios Hardware Modules";
  };

  config = lib.mkIf cfg.enable {

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware = {

      cpu.amd.updateMicrocode = lib.mkDefault true;

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

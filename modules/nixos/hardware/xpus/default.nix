{
  lib,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.hardware.xpus;
in

{
  options.hardware.xpus = with types; {
    enable = mkBoolOpt false "Enable GPU/CPU Modules";
  };

  config = mkIf cfg.enable {

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware = {

      cpu.amd.updateMicrocode = lib.mkDefault true;

      nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = false;
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

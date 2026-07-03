{
  lib,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.shared.services.bluetooth;
in

{
  options.shared.services.bluetooth = with types; {
    enable = mkBoolOpt false "Enable Bluetooth";
  };

  config = mkIf cfg.enable {

    services.blueman.enable = true;

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings = {

        General = {
          # Shows battery charge of connected devices on supported
          # Bluetooth adapters. Defaults to 'false'.
          Experimental = false;
          # When enabled other devices can connect faster to us, however
          # the tradeoff is increased power consumption. Defaults to
          # 'false'.
          FastConnectable = true;
        };

        Policy = {
          # Enable all controllers when they are found. This includes
          # adapters present on start as well as adapters that are plugged
          # in later on. Defaults to 'true'.
          AutoEnable = true;
        };

      };
    };

  };
}

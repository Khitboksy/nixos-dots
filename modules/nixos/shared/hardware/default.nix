{
  lib,
  zenith,
  config,
  pkgs,
  ...
}:
with zenith.lib';
let
  cfg = config.shared.hardware;
in
{
  options.shared.hardware = with lib.types; {
    enable = mkBoolOpt false "Enable Shared Hardware Modules";
  };

  config = lib.mkIf cfg.enable {
    systemd.services = {
      NetworkManager-wait-online.enable = lib.mkForce false;
    };
    networking = {
      firewall.allowedTCPPorts = [ 4096 ];
      useDHCP = lib.mkDefault true;
      networkmanager.enable = true;
    };
    boot = {
      # lib.mkDefault so individual hosts can override (e.g. helios uses the CachyOS kernel)
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
    };
    hardware.enableRedistributableFirmware = true;
  };
}

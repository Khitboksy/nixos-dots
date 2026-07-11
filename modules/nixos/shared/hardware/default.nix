{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.shared.hardware;
in
{
  options.shared.hardware = with types; {
    enable = mkBoolOpt false "Enable Shared Hardware Modules";
  };

  config = mkIf cfg.enable {
    systemd.services = {
      NetworkManager-wait-online.enable = mkForce false;
    };
    networking = {
      firewall.allowedTCPPorts = [ 4096 ];
      useDHCP = mkDefault true;
      networkmanager.enable = true;
    };
    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
    };
    hardware.enableRedistributableFirmware = true;
  };
}

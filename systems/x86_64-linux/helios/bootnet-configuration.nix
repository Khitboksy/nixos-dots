{
  pkgs,
  lib,
  ...
}:

{

  hardware.enableRedistributableFirmware = true;

  boot = {

    supportedFilesystems = [ "ntfs" ];
    kernelPackages = pkgs.linuxPackages_latest;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usb_storage"
      "usbhid"
      "sd_mod"
    ];

    kernelModules = [ "ntsync" ];

  };

  networking = {

    hostName = "helios";
    networkmanager.enable = true;

    firewall.allowedTCPPorts = [
      22
      111
      2049
      4096
    ];

    useDHCP = lib.mkDefault true;
  };

  systemd.services = {
    NetworkManager-wait-online.enable = lib.mkForce false;
  };
}

{

  boot = {

    supportedFilesystems = [ "ntfs" ];

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

    firewall.allowedTCPPorts = [
      111
      2049
      4096
    ];

  };

}

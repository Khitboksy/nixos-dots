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

  networking.hostName = "helios";

}

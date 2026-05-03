{
  fileSystems = {

    "/" = {
      device = "/dev/disk/by-uuid/d8549c68-ef86-425f-8b9b-5125e8973b77";
      fsType = "ext4";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/3e0c8f46-7ef6-4e81-a286-b709e2011c25";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/9861-91BE";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    "/mnt/nix-data" = {
      device = "/dev/disk/by-uuid/69f8977c-153f-40b5-9eea-3066e071bf1c";
      fsType = "ext4";
    };

  };
  swapDevices = [ ];

  #fileSystems."/mnt/oldnix" = {
  #  device = "/dev/disk/by-uuid/fb75032f-14f7-41c9-b79a-27372fdd1bd4";
  #  fsType = "ext4";
  #};
}

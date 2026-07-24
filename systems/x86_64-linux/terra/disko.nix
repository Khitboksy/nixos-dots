{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        swap = {
          size = "4G";
          type = "8200";
          content = {
            type = "swap";
            discardPolicy = "both";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "/root" = {
                mountpoint = "/";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "/home" = {
                mountpoint = "/home";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "/nix" = {
                mountpoint = "/nix";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
            };
          };
        };
      };
    };
  };
  # Non-root subvolumes need this so they're available in early boot
  fileSystems = {
    "/nix".neededForBoot = true;
    "/home".neededForBoot = true;

    # NFS client mount: Helios's shared notes (Obsidian vault)
    "/home/helios/obsidian" = {
      device = "100.122.255.2:/home/helios/shared/notes/helios";
      fsType = "nfs";
      options = [
        "x-systemd.automount"
        "noauto"
        "noatime"
      ];
    };
  };
}

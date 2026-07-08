## SYSTEM related configuration. Add NIXOS SYSTEM options here.
{
  pkgs,
  lib,
  modulesPath,
  ...
}:

{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./bootnet.nix
    ./disk.nix
  ];

  # HIBERNATION SETUP (suspend-to-disk via /swapfile)
  #
  # How it works:
  #   The 32 GiB /swapfile (defined in disk-configuration.nix) sits at priority 0.
  #   The kernel NEVER uses it as regular swap — ZRAM (100) and the encrypted partition
  #   (5) fill first. /swapfile only gets written to when you run:
  #     systemctl hibernate
  #
  # What the kernel needs to find the hibernation image:
  #   boot.resumeDevice  = the BLOCK DEVICE where /swapfile lives (root partition)
  #   resume_offset       = the filesystem block offset where /swapfile starts
  #
  # ===== HOW TO GET resume_offset (after FIRST rebuild): =====
  #
  #   Step 1: sudo nixos-rebuild switch --flake ~/builds#helios
  #           (this creates /swapfile automatically)
  #
  #   Step 2: sudo filefrag -v /swapfile
  #
  #     Output looks like:
  #       File size of /swapfile is 34359738368 (8388608 blocks of 4096 bytes)
  #       ext:     logical_offset:        physical_offset:       length:
  #       0:       0..     0:           2998272..   2998272:      1
  #       1:       1.. 8388607:         2998273..  11386880:  8388607
  #
  #     The FIRST physical_offset number is your resume_offset. In this case 2998272.
  #
  #   Step 3: Uncomment kernelParams below and replace XXX with that number:
  #     kernelParams = [ "resume_offset=2998272" ];
  #
  #   Step 4: sudo nixos-rebuild switch --flake ~/builds#helios
  #
  #   Step 5: Test with: sudo systemctl hibernate
  #           (then press power button to wake — system should resume)
  #
  # ⚠️  DO NOT recreate /swapfile after setting resume_offset. If you ever
  #    delete or recreate it, the offset changes and you must recalculate.
  #
  boot = {
    resumeDevice = "/dev/disk/by-uuid/d8549c68-ef86-425f-8b9b-5125e8973b77"; # root partition (nvme0n1p2)

    # Uncomment after running: sudo filefrag -v /swapfile
    # See above for instructions.
    # kernelParams = [ "resume_offset=XXX" ];
  };

  # Custom NixOS Modules located in ../../../modules/nixos/*
  gaming = {
    enable = true;
    minecraft.enable = true;
  };
  security.sops.enable = true;

  sops.secrets.nixos-cache = {
    sopsFile = ../../../secrets/nixos-cache;
    path = "/run/secrets/nixos-cache.sec";
    format = "binary";
    owner = "root";
    mode = "0400";
  };
  virt.vms.enable = false; # SHELVED TILL I GET ANOTHER GPU

  hardware = {
    systems.helios.enable = true;
  };

  shared = {
    locale.defaultLocale = "en_US.UTF-8";
    hardware = {
      enable = true;
      audio.enable = true;
      swap.enable = true;
    };
    protocols.wayland.enable = true;
    services = {
      bluetooth.enable = true;
      ssh.enable = true;
      tailscale.enable = true;
      vpn.enable = false;
    };
    ui = {
      fonts.enable = true;
      greetd.enable = true;
    };
  };

  services = {
    io.enable = true;
    nfs.enable = true;
    openrgb.enable = true;

    easyeffects.enable = true;

    logrotate.checkConfig = false;
    udisks2.enable = true;

    xserver = {
      xkb = {
        layout = "us";
        variant = "";
      };
      enable = true;
    };

    udev.packages = [ pkgs.libratbag ];
    gvfs.enable = true;
    usbmuxd.enable = true;

    rpcbind.enable = true;

  };

  catppuccin = {
    enable = true;
    autoEnable = false;
  };

  virt.vms.tiny10 = {
    enable = false;
    iso = "/mnt/nix-data/VMs/isos/tiny10-23h2/tiny10-x64-23h2.iso";
    virtioIso = "/mnt/nix-data/VMs/isos/virtio-win-0.1.285.iso";
    memory = 16384;
    vcpu = 8;
    gpu = {
      pci = [ "0000:2b:00.0" ];
      audio = [ "0000:2b:00.1" ];
      usb = [ "0000:2b:00.2" ];
      ucsi = [ "0000:2b:00.3" ];
    };
  };

  # Standard configuration.nix configuration stuff
  programs = {

    fish.enable = true;

    direnv = {
      enable = true;
      enableFishIntegration = true;
    };

    nix-index = {
      enable = true;
      useTerra = true;
    };
  };

  time = {
    timeZone = "America/Chicago";
  };

  security.rtkit.enable = true;

  users = {
    users.helios = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMxx5CYvx7bbRmrFPE2yliWIgTq3xb6mumF103Dmlaup terra-exit"
      ];
      extraGroups = [
        "networkmanager"
        "plugdev"
        "uinput"
      ];
      shell = pkgs.fish;
    };

    groups = {
      libvirtd.members = [ "helios" ];
    };
  };

  snowfallorg.users.helios = {
    create = true;
    admin = true;
    home = {
      enable = true;
    };
  };

  environment = {

    variables = {
      NH_FLAKE = "/home/helios/builds";
    };

    systemPackages = with pkgs; [
      cmake
      meson
      cpio
      swaybg
      xwayland-satellite
      python3Packages.youtube-transcript-api
    ];
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
  };

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      dates = [ "03:45" ];
    };
    settings = {
      sandbox = "relaxed";
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
      secret-key-files = [ "/run/secrets/nixos-cache.sec" ];
    };
  };

  # Nix daemon needs sops-nix to have decrypted the signing key before starting
  systemd.services.nix-daemon = {
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
  };

  home-manager.backupFileExtension = "bk";
  system.stateVersion = "24.11";

}

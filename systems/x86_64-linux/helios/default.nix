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
    ./bootnet-configuration.nix
    ./disk-configuration.nix
  ];

  # Custom NixOS Modules located in ../../../modules/nixos/*
  #apps.steam.enable = true;
  ui.fonts.enable = true;
  protocols.wayland.enable = true;
  apps.steam.enable = true;

  hardware = {
    audio.enable = true;
    xpus.enable = true;
  };

  services = {
    bluetooth.enable = true;
    io.enable = true;
    nfs.enable = true;
    openrgb.enable = true;
    vpn.enable = true;
  };

  # Standard configuration.nix configuration stuff
  programs = {

    fish.enable = true;
    gamemode.enable = true;
    virt-manager.enable = false;

    direnv = {
      enable = true;
      enableBashIntegration = true;
    };
    /*
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
          gamescopeSession.enable = true;
        };
    */
  };

  services = {
    printing.enable = true;
    logrotate.checkConfig = false;
    udisks2.enable = true;

    xserver = {
      xkb = {
        layout = "us";
        variant = "";
      };
      enable = true;
      wacom.enable = true;
    };

    udev.packages = [ pkgs.libratbag ];
    gvfs.enable = true;
    usbmuxd.enable = true;

    rpcbind.enable = true;
  };

  time = {
    timeZone = "America/Chicago";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  security.rtkit.enable = true;

  users = {
    users.helios = {
      isNormalUser = true;
      description = "Taylor";
      extraGroups = [
        "networkmanager"
        "wheel"
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
    systemPackages = [
      (pkgs.lutris.override {
        extraLibraries = pkgs: [
          pkgs.libsForQt5.qt5.qtwayland
          pkgs.wayland
        ];
      })
      pkgs.protonup-qt

      pkgs.piper
      pkgs.libratbag
      pkgs.cmake
      pkgs.meson
      pkgs.cpio
      pkgs.swaybg
      pkgs.xwayland-satellite
    ];
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault "x86_64-linux";
  };

  virtualisation = {
    libvirtd.enable = false;
    spiceUSBRedirection.enable = false;
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
    settings.experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];
  };

  home-manager.backupFileExtension = "bk";
  system.stateVersion = "24.11";

}

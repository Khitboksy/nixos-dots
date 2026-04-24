# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  programs = {
    virt-manager.enable = false;
    direnv = {
      enable = true;
      enableBashIntegration = true;
    };
    fish.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      config = {
        enable = true;
        defaultCompatTool = "Proton-Experimental";
        closeSteam = true;
        apps = {
          deadlock = {
            id = 1422450;
            compatTool = "GE-Proton10-29";
            launchOptions = {
              env = {
                PROTON_USE_NTSYNC = true;
                DXVK_ASYNC = "1";
              };
              args = [
                "-novid"
                "-nojoy"
                "-novsync"
                "+exec autoexec.cfg"
                "-no_prewarm_map"
                "-f"
              ];
              wrappers = [
                (lib.getExe pkgs.gamemode)
                #"/home/helios/.local/bin/mangohud-def"
                pkgs.mangohud
                "gamescope -r 60 -w 1366 -h 768 --force-grab-cursor --rt --adaptive-sync --hdr-enabled=0 --"
              ];
            };
          };
          overwatch = {
            id = 2357570;
            compatTool = "GE-Proton10-29";
            launchOptions = {
              env = {
                SDL_VIDEODRIVER = "x11";
                PROTON_USE_NTSYNC = true;
              };
              wrappers = [
                (lib.getExe pkgs.gamemode)
                "gamescope -f -r 165 -w 1920 -h 1080 --force-grab-cursor --"
              ];
            };
          };
        };
      };
    };

    gamemode.enable = true;
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

    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    udev.packages = [ pkgs.libratbag ];
    gvfs.enable = true;
    usbmuxd.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    hardware = {
      openrgb.enable = true;
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    blacklistedKernelModules = [
      "wacom"
      "hid_uclogic"
    ];
    supportedFilesystems = [ "ntfs" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  ui.fonts.enable = true;

  protocols.wayland.enable = true;

  networking = {
    hostName = "helios";
    networkmanager.enable = true;
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
      pkgs.pwvucontrol
      pkgs.swaybg
      pkgs.xwayland-satellite
      pkgs.openrgb
    ];
  };

  nixpkgs.config.allowUnfree = true;

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
    ];
  };

  home-manager.backupFileExtension = "bk";
  system.stateVersion = "24.11";

  systemd.services = {
    mullvad-auto-connect = {
      description = "Mullvad VPN auto-connect";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = [
          "${pkgs.mullvad}/bin/mullvad auto-connect set on"
          "${pkgs.mullvad}/bin/mullvad connect"
        ];
      };
    };

    ratbagd = {
      enable = true;
      description = "Daemon for configuring gaming mice (used by Piper)";
      serviceConfig = {
        ExecStart = "${pkgs.libratbag}/bin/ratbagd";
        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
    };

    NetworkManager-wait-online.enable = lib.mkForce false;

    openrgb = lib.mkForce {
      description = "OpenRGB SDK Server";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.openrgb}/bin/openrgb --server";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    openrgb-profile = lib.mkForce {
      description = "OpenRGB Profile Loader";
      wantedBy = [ "multi-user.target" ];
      after = [ "openrgb.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.openrgb}/bin/openrgb --profile \"Helios(TMEM).orp\"";
        RemainAfterExit = true;
      };
    };
  };
}

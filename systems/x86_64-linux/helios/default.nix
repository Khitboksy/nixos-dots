# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
    };
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    fish.enable = true;

    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;
  };

  services = {
    printing.enable = true;
    logrotate.checkConfig = false;
    xserver.xkb = {
      layout = "us";
      variant = "";
    };
    xserver.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Mullvad
    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };
    # Enable services and permissions for Piper
    udev.packages = [pkgs.libratbag];

    gvfs.enable = true;

    usbmuxd.enable = true;
    hardware = {
      openrgb.enable = true;
    };
  };

  home-manager.backupFileExtension = "bk";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NTFS compatibility
  boot.supportedFilesystems = ["ntfs"];

  ui.fonts.enable = true;
  protocols.wayland.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "helios"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.helios = {
    isNormalUser = true;
    description = "Taylor";
    extraGroups = ["networkmanager" "wheel" "libvirtd" "plugdev"];
    shell = pkgs.fish;
    initialPassword = "";
    packages = with pkgs; [
      kdePackages.kate
      #vesktop
      bitwarden-desktop
      nh
      #  thunderbird
    ];
  };
  snowfallorg.users.helios = {
    create = true;
    admin = true;

    home = {
      enable = true;
    };
  };
  environment.variables = {NH_FLAKE = "/home/helios/builds";};

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Steam

  # Virt-Manager
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["helios"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 21d";
    };
    optimise = {
      automatic = true;
      dates = ["03:45"];
    };
    settings.experimental-features = ["nix-command" "flakes"];
  };

  hardware.audio.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = [
    # Lutris
    (pkgs.lutris.override {
      extraLibraries = pkgs: [
        pkgs.libsForQt5.qt5.qtwayland
        pkgs.wayland
      ];
    })

    # Only 'x86_64-linux' and 'aarch64-linux' are supported

    pkgs.protonup-qt

    pkgs.piper
    pkgs.libratbag

    pkgs.cmake
    pkgs.meson
    pkgs.cpio
    pkgs.pwvucontrol
    pkgs.mangohud

    pkgs.swaybg

    #  wget

    pkgs.xwayland-satellite
  ];

  systemd.services = {
    ratbagd = {
      # Ensure the Ratbagd service runs
      enable = true;
      description = "Daemon for configuring gaming mice (used by Piper)";
      serviceConfig = {
        ExecStart = "${pkgs.libratbag}/bin/ratbagd";
        Restart = "on-failure";
      };
      wantedBy = ["multi-user.target"];
    };
    NetworkManager-wait-online.enable = lib.mkForce false;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

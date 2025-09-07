# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  programs.direnv.enable = true;
  programs.direnv.enableBashIntegration = true;
  home-manager.backupFileExtension = "bk";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NTFS compatibility
  boot.supportedFilesystems = ["ntfs"];

  nix.settings.experimental-features = ["nix-command" "flakes"];

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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.helios = {
    isNormalUser = true;
    description = "Taylor";
    extraGroups = ["networkmanager" "wheel" "libvirtd" "plugdev"];
    initialPassword = "";
    packages = with pkgs; [
      kdePackages.kate
      vesktop
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

  # Mullvad
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    gamescopeSession.enable = true;
  };

  # Virt-Manager
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["helios"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  programs.gamemode.enable = true;

  hardware.audio.enable = true;

  # Install neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
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
    inputs.zen-browser.packages."${system}".default # beta

    pkgs.git
    pkgs.neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    pkgs.openrgb-with-all-plugins # RGB LED controller
    pkgs.ckan # Comprehensive Kerbal Archive Network. KSP mod manager
    pkgs.btop # better htop
    pkgs.vlc
    pkgs.clonehero
    pkgs.protonup-qt
    pkgs.qbittorrent
    # Mouse
    pkgs.piper
    pkgs.libratbag
    # Fastfetch
    pkgs.fastfetch
    # OBS Studio
    pkgs.obs-studio
    # ROR2 ModManager
    pkgs.r2modman
    pkgs.linux-wifi-hotspot
    pkgs.cmake
    pkgs.meson
    pkgs.cpio
    pkgs.pavucontrol
    pkgs.mangohud
    pkgs.cider-2
    #  wget
  ];
  # Enable services and permissions for Piper
  services.udev.packages = [pkgs.libratbag];

  services.gvfs.enable = true;

  # Ensure the Ratbagd service runs
  systemd.services.ratbagd = {
    enable = true;
    description = "Daemon for configuring gaming mice (used by Piper)";
    serviceConfig = {
      ExecStart = "${pkgs.libratbag}/bin/ratbagd";
      Restart = "on-failure";
    };
    wantedBy = ["multi-user.target"];
  };

  systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

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

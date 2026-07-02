{
  pkgs,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disko.nix
    ./bootnet.nix
  ];

  ui = {
    greetd.enable = true;
    fonts.enable = true;
  };
  protocols.wayland.enable = true;
  security.sops.enable = true;

  hardware = {
    audio.enable = true;
    systems = {
      shared.enable = true;
      terra.enable = true;
    };
    swap.enable = true;
  };

  gaming.minecraft.enable = false;

  services = {
    ssh.enable = true;
    tails = {
      enable = true;
      authKeyFile = "/run/secrets/tailscale-authkey";
    };

    music.enable = true;

    xserver = {
      xkb = {
        layout = "us";
        variant = "";
      };
      enable = false;
    };
  };

  catppuccin = {
    enable = true;
    autoEnable = false;
  };

  programs = {

    fish.enable = true;

    direnv = {
      enable = true;
      enableFishIntegration = true;
    };

    nix-index.enable = true;
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

  users = {
    users.helios = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKdvyTh8FxSq1/QXMDdHnWG19eueLX5ASr3+gjP0McwX"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC1sFljQUl5+wVK6lw4c5aGdYTZLl5PY6kONeYgewG/v nix-index-deploy-key"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2+Nyt/zSiXDRo70/kJffhPWDPWqJdBp6y0oF70zMDE terra-access-key"
      ];
      extraGroups = [
        "networkmanager"
        "plugdev"
        "uinput"
      ];
      shell = pkgs.fish;
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
    systemPackages = with pkgs; [
      xwayland-satellite
    ];
  };

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
  };

  nix.settings = {
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nixos-cache:f5fzlUbraSMLYr+VMIqrvihrGxl3uerbkei7dzTAnD0="
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  home-manager.backupFileExtension = "bak";
  system.stateVersion = "26.05";

}

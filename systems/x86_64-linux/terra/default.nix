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

  security.sops.enable = true;

  hardware = {
    systems.terra.enable = true;
  };

  gaming.minecraft.servers = {
    tekkit2 = {
      enable = true;
    };
  };

  vaultwarden = {
    enable = true;
    domain = "https://terra.tail9a2d08.ts.net";
    adminTokenFile = "/run/secrets/vaultwarden-admin-token";
    signupsAllowed = false;
    invitationsAllowed = true;
  };

  adguardhome.enable = true;

  services = {
    music.enable = true;
    upower.enable = true;
    logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };
    xserver = {
      xkb = {
        layout = "us";
        variant = "";
      };
      enable = false;
    };
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
      tailscale = {
        enable = true;
        authKeyFile = "/run/secrets/tailscale-authkey";
      };
      vpn.enable = false;
    };
    ui = {
      fonts.enable = true;
      greetd.enable = true;
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
        "wheel"
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

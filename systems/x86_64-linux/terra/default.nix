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
    domain = "https://terra.tail9a2d08.ts.net/vault";
    adminTokenFile = "/run/secrets/vaultwarden-admin-token";
    signupsAllowed = false;
    invitationsAllowed = true;
  };

  adguardhome.enable = true;

  virt.vms = {
    enable = true;
    enableGpuPassthrough = false; # Terra has no dGPU

    csp-win = {
      enable = true;
      memory = 12288; # 12 GB
      vcpu = 4;
      diskSize = "50G";
      iso = "/var/lib/libvirt/images/tiny10.iso";
      virtioIso = "/var/lib/libvirt/images/virtio-win.iso";
      graphics = "spice";
    };
  };

  # Tiny HTTP redirect services — tailscale serve proxies to these,
  # which 302 the browser to the direct port URL.
  systemd.services.redirect-cockpit = {
    description = "HTTP 302 redirect: /cockpit → :9090";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = let
        script = pkgs.writeScript "redirect-cockpit" ''
          #!${pkgs.python3}/bin/python3
          from http.server import HTTPServer, BaseHTTPRequestHandler
          class H(BaseHTTPRequestHandler):
              def do_GET(self):
                  self.send_response(302)
                  self.send_header("Location", "https://terra.tail9a2d08.ts.net:9090")
                  self.end_headers()
          HTTPServer(("127.0.0.1", 18090), H).serve_forever()
        '';
      in script;
    };
  };

  systemd.services.redirect-navidrome = {
    description = "HTTP 302 redirect: /navidrome → :4533";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = let
        script = pkgs.writeScript "redirect-navidrome" ''
          #!${pkgs.python3}/bin/python3
          from http.server import HTTPServer, BaseHTTPRequestHandler
          class H(BaseHTTPRequestHandler):
              def do_GET(self):
                  self.send_response(302)
                  self.send_header("Location", "https://terra.tail9a2d08.ts.net:4533")
                  self.end_headers()
          HTTPServer(("127.0.0.1", 18053), H).serve_forever()
        '';
      in script;
    };
  };

  # Persistent tailscale serve routes for path-based service access
  systemd.services.tailscale-serve-routes = {
    description = "Set up tailscale serve routes for services";
    after = [ "tailscaled.service" "redirect-cockpit.service" "redirect-navidrome.service" ];
    requires = [ "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script =
      let
        tailscaleDomains = "${lib.getExe pkgs.tailscale} serve --bg --set-path";
      in
      ''
        ${lib.getExe pkgs.tailscale} serve reset || true
        ${tailscaleDomains} /vault http://127.0.0.1:8222
        ${tailscaleDomains} /cockpit http://127.0.0.1:18090
        ${tailscaleDomains} /navidrome http://127.0.0.1:18053
      '';
  };

  services = {
    music = {
      enable = true;
      musicDirectory = "/srv/music";
    };
    nfs = {
      enable = true;
      exports = [
        "/srv/music 100.122.255.2(rw,sync,no_subtree_check,no_root_squash)"
      ];
    };
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
      settings = {
        global = {
          hide_env_diff = true;
        };
      };
    };

    nix-index.enable = true;
  };

  security.sudo.wheelNeedsPassword = false;

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
    trusted-users = [ "helios" ];
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

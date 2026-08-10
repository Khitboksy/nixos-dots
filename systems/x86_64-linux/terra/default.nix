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
    tlsCertFile = "/var/lib/vaultwarden/tls/fullchain.pem";
    tlsKeyFile = "/var/lib/vaultwarden/tls/privkey.pem";
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

  # 302 redirect services — tailscale serve proxies to these,
  # which bounce the browser to the direct port URL.
  services.redirect = {
    enable = true;
    rules = {
      cockpit = {
        port = 18090;
        target = "https://terra.tail9a2d08.ts.net:9090";
      };
      navidrome = {
        port = 18053;
        target = "https://terra.tail9a2d08.ts.net:4533";
      };
      vaultwarden = {
        port = 18222;
        target = "https://terra.tail9a2d08.ts.net:8222";
      };
    };
  };

  # Persistent tailscale serve routes for path-based service access
  systemd.services.tailscale-serve-routes = {
    description = "Set up tailscale serve routes for services";
    after = [
      "tailscaled.service"
      "redirect-cockpit.service"
      "redirect-navidrome.service"
      "redirect-vaultwarden.service"
    ];
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
        ${tailscaleDomains} /vault http://127.0.0.1:18222
        ${tailscaleDomains} /cockpit http://127.0.0.1:18090
        ${tailscaleDomains} /navidrome http://127.0.0.1:18053
      '';
  };

  # Tailscale TLS cert provisioning.
  # Runs on boot and daily; copies certs to locations needed by
  # Vaultwarden, nginx (Cockpit proxy), and Navidrome.
  systemd.services.tailscale-cert = {
    description = "Provision Tailscale TLS certificates";
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    before = [
      "vaultwarden.service"
      "nginx.service"
      "navidrome.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      TS_CERT_DIR="/var/lib/tailscale/certs"
      HOSTNAME="terra.tail9a2d08.ts.net"

      # Provision certs if missing
      if [ ! -f "$TS_CERT_DIR/$HOSTNAME.crt" ] || [ ! -f "$TS_CERT_DIR/$HOSTNAME.key" ]; then
        ${lib.getExe pkgs.tailscale} cert "$HOSTNAME" || true
      fi

      if [ -f "$TS_CERT_DIR/$HOSTNAME.crt" ] && [ -f "$TS_CERT_DIR/$HOSTNAME.key" ]; then
        # Vaultwarden (its own directory, owned by vaultwarden)
        mkdir -p /var/lib/vaultwarden/tls
        cp "$TS_CERT_DIR/$HOSTNAME.crt" /var/lib/vaultwarden/tls/fullchain.pem
        cp "$TS_CERT_DIR/$HOSTNAME.key" /var/lib/vaultwarden/tls/privkey.pem
        chown vaultwarden:vaultwarden /var/lib/vaultwarden/tls/*.pem
        chmod 600 /var/lib/vaultwarden/tls/privkey.pem

        # Shared location for nginx and Navidrome (world-readable cert, restricted key)
        mkdir -p /etc/tailscale-certs
        cp "$TS_CERT_DIR/$HOSTNAME.crt" /etc/tailscale-certs/fullchain.pem
        cp "$TS_CERT_DIR/$HOSTNAME.key" /etc/tailscale-certs/privkey.pem
        chmod 644 /etc/tailscale-certs/fullchain.pem
        chmod 640 /etc/tailscale-certs/privkey.pem
        chown root:nginx /etc/tailscale-certs/privkey.pem
      fi
    '';
  };

  systemd.timers.tailscale-cert = {
    description = "Renew Tailscale TLS certificates daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "24h";
    };
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
        "/srv/lyrics 100.122.255.2(rw,sync,no_subtree_check,no_root_squash)"
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

  # Lyrics mirror: NFS-shared with helios (mounted at /mnt/nix-data/media/lyrics)
  systemd.tmpfiles.settings."10-srv-lyrics"."/srv/lyrics".d = {
    user = "helios";
    group = "users";
    mode = "0755";
  };

  # Cockpit: move to backend port, nginx terminates TLS on 9090
  services.cockpit.port = 9091;

  # Nginx: TLS termination for Cockpit
  services.nginx = {
    enable = true;
    virtualHosts."terra.tail9a2d08.ts.net" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 9090;
          ssl = true;
        }
      ];
      sslCertificate = "/etc/tailscale-certs/fullchain.pem";
      sslCertificateKey = "/etc/tailscale-certs/privkey.pem";
      forceSSL = false;
      locations."/" = {
        proxyPass = "http://127.0.0.1:9091";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
      extraConfig = ''
        ssl_certificate /etc/tailscale-certs/fullchain.pem;
        ssl_certificate_key /etc/tailscale-certs/privkey.pem;
      '';
    };
  };

  # Ensure nginx log files are owned by the nginx user.
  # LogsDirectory=nginx creates the directory correctly, but files inside
  # can end up owned by root from prior runs. This fixes them before
  # nginx drops privileges.
  systemd.services.nginx.preStart = lib.mkAfter ''
    chown nginx:nginx /var/log/nginx/access.log 2>/dev/null || true
  '';

  # Navidrome: enable TLS with Tailscale certs
  services.navidrome.settings = {
    TLSCertFile = "/etc/tailscale-certs/fullchain.pem";
    TLSKeyFile = "/etc/tailscale-certs/privkey.pem";
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
      isNormalUser = true;
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

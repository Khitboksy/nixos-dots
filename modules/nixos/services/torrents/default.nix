{
  lib,
  config,
  zenith,
  pkgs,
  ...
}:

with zenith.lib';

let
  cfg = config.services.torrents;
in

{

  options.services.torrents = with lib.types; {
    enable = mkBoolOpt' false;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      spek
      qbittorrent
    ];

    services = {
      /*
        qbittorrent = {
          enable = true;
        };
      */

      slskd = {
        enable = true;
        environmentFile = config.sops.secrets.slsk-net.path;
        settings = {
          shares = {
            directories = [ "/srv/music" ];
            # Share only flac — filters are regex, exclusion-only, and case-insensitive.
            # Explicit extension blacklist, NOT a catch-all: filters also match
            # directory paths, and a catch-all would hide dotted album names
            # like "K.G", "L.W" or "Good Kid M.a.a.d City".
            filters = [
              "\\.(mp3|m4a|aac|ogg|opus|wav|wma|jpg|jpeg|png|gif|webp|lrc|cue|log|pdf|zip|nfo|txt)$"
            ];
          };
          web = {
            port = 5030;
            # Serve under /slskd so tailscale serve can proxy
            # https://terra...ts.net/slskd -> 127.0.0.1:5030
            url_base = "/slskd";
          };

          # Final downloads land in helios's home. Key is directories.downloads
          # (NOT downloads.path — that key doesn't exist). Dir must pre-exist
          # and be writable: slskd validates at startup and refuses to start
          # otherwise. Incomplete files stay at the default /var/lib/slskd/incomplete.
          directories.downloads = "/home/helios/Downloads/slsk";
        };
      };
    };

    systemd.services.slskd.serviceConfig = {
      EnvironmentFile = lib.mkForce [
        config.sops.secrets.slsk-net.path
        config.sops.secrets.slsk-web.path
      ];

      # Allow downloads in helios's home: upstream sets ProtectHome=true
      # (masks /home entirely) and ProtectSystem=strict (whole fs read-only).
      # "no" unmasks /home; ReadWritePaths lifts the strict read-only for the
      # download dir only. POSIX perms (helios:slskd 2775, /home 701) do the
      # actual access gating.
      ProtectHome = lib.mkForce "no";
      ReadWritePaths = [ "/home/helios/Downloads/slsk" ];
    };

    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 5030 ];
  };

}

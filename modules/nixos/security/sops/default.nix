{
  lib,
  zenith,
  config,
  pkgs,
  ...
}:

with zenith.lib';

let
  cfg = config.security.sops;
in

{
  options.security.sops = with lib.types; {
    enable = mkBoolOpt false "Enable sops-nix secret provisioning";
  };

  config = lib.mkIf cfg.enable {
    sops = {
      age.keyFile = "/etc/sops/keys.txt";
      secrets = {
        lastfm = {
          sopsFile = ../../../../secrets/lastfm;
          format = "binary";
          owner = "helios";
          mode = "0400";
        };
        # Last.fm API key + shared secret, consumed by Navidrome as an
        # environment file so they never land in the world-readable store.
        navidrome-lastfm = {
          sopsFile = ../../../../secrets/navidrome-lastfm;
          path = "/run/secrets/navidrome-lastfm.env";
          format = "binary";
          owner = "root";
          mode = "0400";
        };
        git_mcp_pat = {
          sopsFile = ../../../../secrets/git_mcp_pat;
          path = "/run/secrets/git_mcp_pat.env";
          format = "binary";
          owner = "helios";
          mode = "0400";
        };
        openrouter = {
          sopsFile = ../../../../secrets/openrouter;
          path = "/run/secrets/openrouter.env";
          format = "binary";
          owner = "helios";
          mode = "0400";
        };
        git_mcp_cat = {
          sopsFile = ../../../../secrets/git_mcp_cat;
          path = "/run/secrets/git_mcp_cat.env";
          format = "binary";
        };
        odysseus = {
          sopsFile = ../../../../secrets/odysseus;
          path = "/run/secrets/odysseus.env";
          format = "binary";
          owner = "helios";
          mode = "0400";
        };
        tailscale-authkey = {
          sopsFile = ../../../../secrets/tailscale-authkey;
          path = "/run/secrets/tailscale-authkey";
          format = "binary";
          owner = "root";
          mode = "0400";
        };
        vaultwarden-admin-token = {
          sopsFile = ../../../../secrets/vaultwarden-admin-token;
          path = "/run/secrets/vaultwarden-admin-token";
          format = "binary";
          owner = "root";
          mode = "0400";
        };
        playit = {
          sopsFile = ../../../../secrets/playit;
          format = "binary";
          owner = "root";
          mode = "0400";
        };
        cloudflared-niri = {
          sopsFile = ../../../../secrets/cloudflared-niri;
          format = "binary";
          owner = "root";
          mode = "0400";
        };
        anki = {
          sopsFile = ../../../../secrets/anki;
          format = "binary";
          owner = "root";
          mode = "0400";
        };
        slsk-net = {
          sopsFile = ../../../../secrets/slsk-net;
          path = "/run/secrets/slsk-net.env";
          format = "binary";
          owner = "root";
          mode = "0400";
        };
        slsk-web = {
          sopsFile = ../../../../secrets/slsk-web;
          path = "/run/secrets/slsk-web.env";
          format = "binary";
          owner = "root";
          mode = "0400";
        };
      };
    };
  };
}

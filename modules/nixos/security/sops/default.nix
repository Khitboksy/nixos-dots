{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.security.sops;
in

{
  options.security.sops = with types; {
    enable = mkBoolOpt false "Enable sops-nix secret provisioning";
  };

  config = mkIf cfg.enable {
    sops = {
      age.keyFile = "/etc/sops/keys.txt";
      secrets = {
        lastfm = {
          sopsFile = ../../../../secrets/lastfm;
          format = "binary";
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
      };
    };
  };
}

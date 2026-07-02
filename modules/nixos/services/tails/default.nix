{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.services.tails;
in

{
  options.services.tails = with types; {
    enable = mkBoolOpt false "Enable Tailscale";

    authKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = ''
        Path to a file containing a Tailscale auth key (or empty for
        ephemeral auth). When set, Tailscale will auto-authenticate
        on boot without needing to run `tailscale up` manually.

        Get an auth key from: https://login.tailscale.com/admin/settings/authkeys

        Without this, you must run `sudo tailscale up` once after first
        enable. After that, Tailscale remembers the session across reboots.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      authKeyFile = cfg.authKeyFile;
    };
  };
}

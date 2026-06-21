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
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}

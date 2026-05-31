{
  lib,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.services.tailscale;
in

{
  options.services.tailscale = with types; {
    enable = mkBoolOpt true "Enable Tailscale";
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
  };
}

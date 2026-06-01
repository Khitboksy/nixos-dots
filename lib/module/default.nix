{
  lib,
  ...
}:
with lib;
rec {
  mkOpt =
    type: default: description:
    mkOption { inherit type default description; };

  mkOpt' = type: default: mkOpt type default null;

  mkBoolOpt = mkOpt types.bool;

  mkStringOpt = mkOpt types.str;

  mkBoolOpt' = mkOpt' types.bool;

  mkPathOpt = mkOpt types.path;

  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };

  isDarwin = pkgs: pkgs.stdenv.isDarwin;

  # Base graphical-session service unit. Apply with:
  #   systemd.user.services.<name> = mkGraphicalService { Unit.Description = "..."; Service.ExecStart = "..."; };
  mkGraphicalService = recursiveUpdate {
    Unit.PartOf = [ "graphical-session.target" ];
    Unit.After = [ "graphical-session.target" ];
    Install.WantedBy = [ "graphical-session.target" ];
  };
}

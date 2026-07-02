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

  mkBoolOpt' = mkOpt' types.bool;

  mkStringOpt = mkOpt types.str;

  mkStringOpt' = mkOpt' types.str;

  mkStringListOpt = mkOpt (types.listOf types.str);

  mkPathOpt = mkOpt types.path;

  mkPathOpt' = mkOpt' types.path;

  mkEnumOpt =
    values: default: description:
    mkOpt (types.enum values) default description;

  mkEnumOpt' = values: default: mkEnumOpt values default null;

  isDarwin = pkgs: pkgs.stdenv.isDarwin;

  # Base graphical-session service unit. Apply with:
  #   systemd.user.services.<name> = mkGraphicalService { Unit.Description = "..."; Service.ExecStart = "..."; };
  mkGraphicalService = recursiveUpdate {
    Unit.PartOf = [ "graphical-session.target" ];
    Unit.After = [ "graphical-session.target" ];
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Import all .nix files from a directory (excluding default.nix) and merge into one attrset.
  # If a file is a function, it's called with { lib } merged with extraArgs.
  # If it's a plain set, it's used as-is.
  importDir =
    dir: extraArgs:
    builtins.foldl' (
      acc: f:
      if f == "default.nix" || !strings.hasSuffix ".nix" f then
        acc
      else
        let
          imported = import (dir + "/${f}");
        in
        acc // (if builtins.isFunction imported then imported ({ inherit lib; } // extraArgs) else imported)
    ) { } (builtins.attrNames (builtins.readDir dir));
}

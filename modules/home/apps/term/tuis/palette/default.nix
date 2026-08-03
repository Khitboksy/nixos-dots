{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.apps.term.tuis.palette;
in

{
  options.apps.term.tuis.palette = with types; {
    enable = mkBoolOpt' true;

    defaultDir = mkPathOpt null "Pick the default palette to open";
    themeFile = mkStringOpt "theme.json" ''
      Can be either a file name (local to ~/.config/palette/themes)
      or absolute /home/helios/palette/test.json)
    '';
    extraDirs = mkStringListOpt [ ] "Extra directories to scan";
    dirFormats = mkAttrOpt { } "Per-directory format overrides";
  };

  config = mkIf cfg.enable {

    programs.palette = {
      enable = true;
      defaultDir = cfg.defaultDir;
      themeFile = cfg.themeFile;
      extraDirs = cfg.extraDirs;
      dirFormats = cfg.dirFormats;
    };

  };
}

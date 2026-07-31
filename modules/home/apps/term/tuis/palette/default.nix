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
  system = pkgs.stdenv.hostPlatform.system;
  tomlFormat = pkgs.formats.toml { };
  configValue = {
    default_dir = cfg.defaultDir;
    theme_palette = cfg.themeFile;
    extra_dirs = cfg.extraDirs;
    dir_formats = cfg.dirFormats;
  };
  tomlFile = tomlFormat.generate "palette-config.toml" configValue;
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

    home.packages = [
      inputs.palette.packages."${system}".default
    ];

    xdg.configFile."palette/config.toml".source = tomlFile;
  };
}

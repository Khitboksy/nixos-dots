{
  lib,
  zenith,
  config,
  ...
}:

with zenith.lib';

let
  cfg = config.apps.term.tuis.palette;
in

{
  options.apps.term.tuis.palette = with lib.types; {
    enable = mkBoolOpt' false;

    default = {
      dir = mkStringOpt null "Default palette directory to open on launch";
      palette = mkStringOpt null "Optional default palette to open on launch";
    };
    themeFile = mkStringOpt "theme.json" ''
      Can be either a file name (local to ~/.config/palette/themes)
      or absolute /home/helios/palette/test.json)
    '';
    extraDirs = mkStringListOpt [ ] "Extra directories to scan";
    dirFormats = mkAttrOpt { } "Per-directory format overrides";
  };

  config = lib.mkIf cfg.enable {

    programs.palette-tui = {
      enable = true;
      default = {
        dir = cfg.default.dir;
        palette = cfg.default.palette;
      };
      themeFile = cfg.themeFile;
      extraDirs = cfg.extraDirs;
      dirFormats = cfg.dirFormats;
    };

    # Add mod+p to niri binds to spawn palette
    wayland.windowManager.niri.settings.binds = {
      "Mod+P" = {
        spawn = [
          "kitty"
          "--class"
          "kitty-palette"
          "--title"
          "palette"
          "-e"
          "palette"
        ];
      };
    };
  };
}

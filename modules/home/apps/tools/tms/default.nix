{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.apps.tools.tms;
in
{
  options.apps.tools.tms = with types; {
    enable = mkBoolOpt false "Enable Tmux Sessionizer (tms)";
    paths = mkOpt (listOf str) [ "~/builds" ] "Paths to search for git repos";
    defaultSession = mkOpt (nullOr str) null "Default session to switch to when killing";
  };

  config = mkIf cfg.enable {
    xdg.configFile = {
      "tms/config.toml" =
        let
          pathsStr = builtins.concatStringsSep ",\n  " (map (p: "\"${p}\"") cfg.paths);
        in
        pkgs.writeTextDir "tms-config.toml" ''
          # Tmux Sessionizer Configuration

          search_paths = [
            ${pathsStr}
          ]
          ${lib.optionalString (cfg.defaultSession != null) ''session = "${cfg.defaultSession}"''}

          # Show basename instead of full path
          full_path = false
        '';
    };
  };
}

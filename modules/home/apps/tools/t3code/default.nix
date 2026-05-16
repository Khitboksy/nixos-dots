{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.apps.tools.t3code;
  system = pkgs.stdenv.hostPlatform.system;
in

{
  options.apps.tools.t3code = with types; {
    enable = mkBoolOpt false "Enable T3 Code desktop application";
  };

  config = mkIf cfg.enable {
    # Add appimage-run so the wrapper can find it
    home.packages = [
      pkgs.appimage-run
      inputs.t3code-flake.packages.${system}
    ];

    xdg.desktopEntries.t3code = {
      name = "T3 Code";
      genericName = "AI Coding Agent Harness";
      comment = "A minimal web GUI for coding agents";
      exec = "${inputs.t3code-flake.packages.${system}}/bin/t3code %U";
      terminal = false;
      categories = [ "Development" "IDE" ];
      startupNotify = true;
    };
  };
}
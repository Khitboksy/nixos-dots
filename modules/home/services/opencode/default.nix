{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib;
with lib.custom; let
  cfg = config.services.opencode;
  system = pkgs.stdenv.hostPlatform.system;
  openpkg = inputs.opencode.packages.${system}.default;
  mkService = recursiveUpdate {
    Unit.PartOf = ["graphical-session.target"];
    Unit.After = ["graphical-session.target"];
    Install.WantedBy = ["graphical-session.target"];
  };
in {
  options.services.opencode = with types; {
    enable = mkBoolOpt true "Enable OpenCode AI coding agent";
    package = mkOpt types.package openpkg "OpenCode package";
    port = mkOpt types.port 4096 "Port for opencode server";
    hostname = mkOpt types.str "127.0.0.1" "Hostname for opencode server";
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      package = cfg.package;
      settings = {
        permission = {
          git = "deny";
        };
        server = {
          port = cfg.port;
          hostname = cfg.hostname;
        };
        mcp = {
          nixos = {
            type = "local";
            command = ["${inputs.mcp-nixos.packages.${system}.default}/bin/mcp-nixos"];
          };
        };
      };
    };
    systemd.user.services = {
      opencode = mkService {
        Unit.Description = "OpenCode Server";
        Service = {
          ExecStart = "${openpkg}/bin/opencode serve --port ${toString cfg.port} --hostname ${cfg.hostname}";
          Restart = "always";
        };
      };
    };
    home.file.".opencode/agents" = {
      source = ./agents;
      recursive = true;
    };
  };
}

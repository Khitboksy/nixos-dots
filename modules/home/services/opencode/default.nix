{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
with lib;
with lib.custom;
let
  cfg = config.services.opencode;
  system = pkgs.stdenv.hostPlatform.system;
  openpkg = pkgs.opencode;

  mkService = recursiveUpdate {
    Unit.PartOf = [ "graphical-session.target" ];
    Unit.After = [ "graphical-session.target" ];
    Install.WantedBy = [ "graphical-session.target" ];
  };
in
{
  options.services.opencode = with types; {
    enable = mkBoolOpt true "Enable OpenCode AI coding agent";
    package = mkOpt types.package openpkg "OpenCode package";
    port = mkOpt types.port 4096 "Port for opencode server";
    hostname = mkOpt types.str "127.0.0.1" "Hostname for opencode server";
    model = mkOpt types.str "openrouter/minimax/minimax-m2.5:free" "Model to use for OpenCode";
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      package = cfg.package;
      settings = {
        # Enable OpenRouter provider
        provider = {
          openrouter = {
            # API key loaded from environment variable
          };
        };

        model = cfg.model;
        # OpenRouter enabled via provider config
        permission = {
          git = "deny";
        };
        server = {
          port = cfg.port;
          hostname = cfg.hostname;
        };
        default_agent = "minerva";
        agent = {
          minerva.model = cfg.model;
        };
        mcp = {
          nixos = {
            type = "local";
            command = [ "${inputs.mcp-nixos.packages.${system}.default}/bin/mcp-nixos" ];
          };
          context7 = {
            type = "remote";
            url = "https://mcp.context7.com/mcp";
          };
          filesystem = {
            type = "local";
            command = [
              "${pkgs.mcp-server-filesystem}/bin/mcp-server-filesystem"
              "/home/helios"
            ];
          };
          github = {
            type = "local";
            command = [
              "${pkgs.github-mcp-server}/bin/github-mcp-server"
              "stdio"
              "--read-only"
            ];
          };
          "sequential-thinking" = {
            type = "local";
            command = [ "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking" ];
          };
        };
      };
    };

    systemd.user.services.minerva = mkService {
      Unit.Description = "OpenCode Server";
      Service = {
        ExecStart = "${openpkg}/bin/opencode serve --port ${toString cfg.port} --hostname ${cfg.hostname}";
        Restart = "always";

        # Load OpenRouter key from env file
        EnvironmentFile = [
          "/home/helios/secrets/git_mcp_pat.env"
          "/home/helios/secrets/openrouter.env"
        ];
      };
    };

    home.file = {
      ".opencode/agents" = {
        source = ./agents;
        recursive = true;
      };
      ".opencode/themes/helios-mocha.json" = {
        source = ./config/themes/helios-mocha.json;
      };
      ".opencode/tui.json" = {
        text = builtins.toJSON {
          theme = "helios-mocha";
        };

      };
    };
  };
}

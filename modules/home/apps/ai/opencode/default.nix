{
  config,
  pkgs,
  inputs,
  lib,
  zenith,
  ...
}:

with zenith.lib';

let

  cfg = config.apps.ai.opencode;

in

{
  options.apps.ai.opencode = with lib.types; {
    enable = mkBoolOpt false "Enable OpenCode AI coding agent";
  };

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      bun
    ];

    programs.opencode = with pkgs; {
      enable = true;
      package = opencode;
      settings = {
        default_agent = "minerva";
        mcp = config.apps.ai.mcps.opencode;
        permission = {
          lsp = "allow";
        };

        server = {
          hostname = "127.0.0.1";
          port = 4096;
          mdns = false;

        };

        provider.${config.apps.ai.provider} = { };

        plugin = [
          "@mohak34/opencode-notifier@latest"
        ];

        references = {
          builds = {
            path = "/home/helios/builds";
            description = ''
              NixOS flake configuration:
              Contains the home/system config and modules for
              uers and hosts, terra and helios
            '';
          };
          repos = {
            path = "/home/helios/repos";
            description = ''
              Git repos for personal projects:
              Git rules apply, like no staging with-out permission,
              no creating comits, and asking to create branches before
              doing so.
            '';
          };
          notes = {
            path = "/home/helios/shared/notes/helios";
            description = ''
              Obsidian vault for notes and documentation:
              Sorted by <group>/<item>.md
            '';
          };
          src = {
            path = "/home/helios/src";
            description = ''
              Repos that dont belong to us, organized as 'username/repo'
              Git rules are even more strict, with git commands completely banned
              unless requested
            '';
          };
          toolbox = {
            path = "/tmp/opencode";
            description = ''
              This is your personal toolbox.
              It follows a semi-strict organizational structure to keep objects sepperated
              Scripts, logging, git clones, and /tmp/ usage is done here instead
            '';
          };
        };

      }
      // importDir ./config {
        inherit
          config
          inputs
          lib

          # pkgs
          nil
          ;
      };

    };

    systemd.user.services.jupiter = mkGraphicalService {
      Unit.Description = "OpenCode Server";

      Service = {

        ExecStart = "${pkgs.opencode}/bin/opencode serve";
        Restart = "always";

        Environment = [
          "SQLITE_JOURNAL_MODE=WAL"
          "SQLITE_SYNCHRONOUS=NORMAL"
          # NFS Shares
          "XDG_DATA_HOME=/home/helios/shared"
          "OPENCODE_DB_PATH=/home/helios/shared/opencode/opencode-stable.db"
          # Enable experimental LSP tool for AI code intelligence
          "OPENCODE_EXPERIMENTAL_LSP_TOOL=true"
        ];

        EnvironmentFile = [
          "${toString config.apps.ai.envFiles}/openrouter.env"
          "${toString config.apps.ai.envFiles}/git_mcp_pat.env"
        ];

      };
    };

    xdg.configFile = {

      "opencode/agents" = {
        source = ./config/agents;
        recursive = true;
      };

      "opencode/plugins" = {
        source = ./config/plugins;
        recursive = true;
      };

      "opencode/skills" = {
        source = ./config/skills;
        recursive = true;
      };

      "opencode/mcps" = {
        source = ../mcps/servers;
        recursive = true;
      };

      "opencode/tui.json" = {
        text = builtins.toJSON {
          theme = "helios-opencodeTheme";
          layout = "helios-opencodeLayout";
        };
      };

      "opencode/themes/helios-opencodeTheme.json" = {
        text = (import ./config/themes/helios-opencodeTheme.nix) { inherit lib; };
      };

      "opencode/layouts/helios-opencodeLayout.json" = {
        text = import ./config/layouts/helios-opencodeLayout.nix;
      };

    };
  };
}

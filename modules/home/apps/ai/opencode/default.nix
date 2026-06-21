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

  cfg = config.apps.ai.opencode;
  system = pkgs.stdenv.hostPlatform.system;

in

{
  options.apps.ai.opencode = with types; {
    enable = mkBoolOpt false "Enable OpenCode AI coding agent";
  };

  config = mkIf cfg.enable {

    home.packages = [
      pkgs.bun
      inputs.mcp-nixos.packages.${system}.default
    ];

    programs.opencode = {
      enable = true;
      package = pkgs.opencode;
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

      }

      // importDir ./config { inherit config inputs pkgs; };

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

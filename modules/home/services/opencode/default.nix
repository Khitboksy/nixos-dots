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
  pkg = pkgs.opencode;
  agents = "file:./agents";
  model = "opencode/minimax-m2.5-free";
  mkService = recursiveUpdate {
    Unit.PartOf = [ "graphical-session.target" ];
    Unit.After = [ "graphical-session.target" ];
    Install.WantedBy = [ "graphical-session.target" ];
  };
in
{
  options.services.opencode = with types; {
    enable = mkBoolOpt true "Enable OpenCode AI coding agent";
  };

  config = mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      package = pkg;
      settings = {
        # Defines the `opecode serve` args (127.0.0.1)
        server = {
          hostname = "localhost"; # Default
          port = 4096; # Deafult
          mdns = false; # True = 0.0.0.0:4096
        };
        # We load API key via env-var on jupiter.service
        provider.openrouter = { };
        permission = {
          git = "ask";
        };
        default_agent = "minerva";
        plugin = [
          "@mohak34/opencode-notifier@latest"
        ];
        agent = {
          minerva = {
            mode = "primary";
            model = "${model}";
            prompt = "{${agents}/minerva.md}";
          };
          flavius = {
            mode = "subagent";
            model = "${model}";
            prompt = "{${agents}/flavius.md}";
          };
          ceasar = {
            mode = "subagent";
            model = "${model}";
            prompt = "{${agents}/ceasar.md}";
          };
          gaius = {
            mode = "subagent";
            model = "${model}";
            prompt = "{${agents}/gaius.md}";
          };
          vestal = {
            mode = "subagent";
            model = "${model}";
            prompt = "{${agents}/vestal.md}";
          };
          thermae = {
            mode = "subagent";
            model = "${model}";
            prompt = "{${agents}/thermae.md}";
          };
          naturalis = {
            mode = "subagent";
            model = "${model}";
            prompt = "{${agents}/naturalis.md}";
          };
          pytheas = {
            mode = "subagent";
            model = "${model}";
            prompt = "${agents}/pytheas.md";
          };
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
              "/home/helios/builds"
              "/home/helios/shared"
              "/home/helios/.config "
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
          sequential-thinking = {
            type = "local";
            command = [ "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking" ];
          };
          web-search = {
            type = "local";
            command = [
              "npx"
              "-y"
              "@zhafron/mcp-web-search"
            ];
            enabled = true;
            environment = {
              DEFAULT_SEARCH_PROVIDER = "searxng";
              SEARXNG_URL = "https://search.zoeys.computer/search";
            };
          };
          sqlite = {
            type = "local";
            command = [
              "node"
              "${config.home.homeDirectory}/.config/opencode/mcps/memory-db-mcp/server.mjs"
            ];
          };
        };
      };
    };

    systemd.user.services.jupiter = mkService {
      Unit.Description = "OpenCode Server";
      #serves a listening server at locahost:4096
      Service = {
        ExecStart = "${pkg}/bin/opencode serve";
        Restart = "always";
        Environment = [
          "SQLITE_JOURNAL_MODE=WAL"
          "SQLITE_SYNCHRONOUS=NORMAL"
          # NFS Shares
          "XDG_DATA_HOME=/home/helios/shared"
          "OPENCODE_DB_PATH=/home/helios/shared/opencode/opencode-stable.db"
        ];
        EnvironmentFile = [
          "/home/helios/secrets/git_mcp_pat.env"
          "/home/helios/secrets/openrouter.env"
        ];
      };
    };
    xdg.configFile = {

      "opencode/agents" = {
        source = ./config/agents;
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

      "opencode/plugins/opencodeNotifier.json" = {
        text = import ./config/plugins/opencodeNotifier.nix;
      };

      # MCP Server scripts - reproducible from Nix
      "opencode/mcps/memory-db-mcp/package.json" = {
        text = builtins.toJSON (import ./config/mcps/memory-db-mcp/package.nix);
      };
      "opencode/mcps/memory-db-mcp/server.mjs" = {
        text = (import ./config/mcps/memory-db-mcp/server.nix);
      };
    };
  };
}

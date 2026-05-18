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

    home.packages = [
      inputs.mcp-nixos.packages.${system}.default
    ];

    programs.opencode = {
      enable = true;
      package = pkgs.opencode;
      settings = {

        lsp = (import ./config/lsp.nix) { inherit pkgs; };

        agent = (import ./config/agent.nix) { inherit model agents; };
        default_agent = "minerva";
        permission = {
          lsp = "allow";
        };

        mcp = (import ./config/mcp.nix) { inherit inputs pkgs; };
        
        # Defines the `opecode serve` args (127.0.0.1)
        server = {
          hostname = "127.0.0.1"; # Default
          port = 4096; # Deafult
          mdns = false; # True = 0.0.0.0:4096
        
        };
        # We load API key via env-var in services.jupiter
        provider.openrouter = { };
        
        plugin = [
          "@mohak34/opencode-notifier@latest"
        ];
      };
    };

    systemd.user.services.jupiter = mkService {
      Unit.Description = "OpenCode Server";
      #serves a listening server at locahost:4096
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

      "opencode/plugins" = {
        source = ./config/plugins;
        recursive = true;
      };

      "opencode/mcps" = {
        source = ./config/mcps;
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

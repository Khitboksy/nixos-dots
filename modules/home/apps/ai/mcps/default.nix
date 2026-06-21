{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:

with lib;
with lib.custom;

let
  system = pkgs.stdenv.hostPlatform.system;

  mkStdio = name: command: args: env: {
    inherit name;
    transport = "stdio";
    inherit command;
    args = builtins.toJSON args;
    env = builtins.toJSON env;
  };

in

{
  options.apps.ai.mcps =
    with types;
    mkOption {
      type = attrsOf anything;
      default = { };
      description = "MCP server definitions shared across AI apps (opencode + odysseus formats)";
    };

  config.apps.ai.mcps = {

    opencode = {
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
          "/home/helios/.config"
          "/home/helios/repos"
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
          SEARXNG_URL = "https://search.tezzzzaa.com/search";
        };
      };

      memory-db = {
        type = "local";
        command = [
          "bash"
          "-c"
          "cd ${config.home.homeDirectory}/.config/opencode/mcps/memory-db-mcp && node server.cjs"
        ];
      };

      bun = {
        type = "local";
        command = [
          "bunx"
          "--bun"
          "mcp-bun@latest"
        ];
        environment = {
          DISABLE_NOTIFICATIONS = "true";
        };
      };

    };

    odysseus = [
      (mkStdio "nixos" "${inputs.mcp-nixos.packages.${system}.default}/bin/mcp-nixos" [ ] { })

      # context7 is remote (SSE/HTTP) — handled via odysseus UI

      (mkStdio "filesystem" "${pkgs.mcp-server-filesystem}/bin/mcp-server-filesystem" [
        "/home/helios/builds"
        "/home/helios/shared"
        "/home/helios/.config"
        "/home/helios/repos"
        "/tmp/opencode"
      ] { })

      (mkStdio "github" "${pkgs.github-mcp-server}/bin/github-mcp-server" [ "stdio" "--read-only" ] { })

      (mkStdio "sequential-thinking"
        "${pkgs.mcp-server-sequential-thinking}/bin/mcp-server-sequential-thinking"
        [ ]
        { }
      )

      (mkStdio "web-search" "npx" [ "-y" "@zhafron/mcp-web-search" ] {
        DEFAULT_SEARCH_PROVIDER = "searxng";
        SEARXNG_URL = "https://search.tezzzzaa.com/search";
      })

      (mkStdio "memory-db" "bash" [
        "-c"
        "cd ${config.home.homeDirectory}/.config/opencode/mcps/memory-db-mcp && node server.cjs"
      ] { })

      (mkStdio "bun" "bunx" [ "--bun" "mcp-bun@latest" ] {
        DISABLE_NOTIFICATIONS = "true";
      })
    ];

  };
}

{
  lib,
  zenith,
  pkgs,
  config,
  inputs,
  ...
}:

with zenith.lib';

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
    with lib.types;
    lib.mkOption {
      type = attrsOf anything;
      default = { };
      description = "MCP server definitions shared across AI apps (opencode + odysseus formats)";
    };

  config = {
    apps.ai.mcps = {

      opencode = {
        nixos = {
          type = "local";
          command = [ "${lib.getExe pkgs.mcp-nixos}" ];
        };

        context7 = {
          type = "remote";
          url = "https://mcp.context7.com/mcp";
        };

        filesystem = {
          type = "local";
          command = [
            "${lib.getExe pkgs.mcp-server-filesystem}"
            "/home/helios/builds"
            "/home/helios/shared"
            "/home/helios/.config"
            "/home/helios/repos"
            "/home/helios/notes"
            "/var/opencode"
          ];
        };

        github = {
          type = "local";
          command = [
            "${lib.getExe pkgs.github-mcp-server}"
            "stdio"
            "--read-only"
          ];
        };

        sequential-thinking = {
          type = "local";
          command = [ "${lib.getExe pkgs.mcp-server-sequential-thinking}" ];
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

        firefox-devtools = {
          type = "local";
          command = [
            "npx"
            "-y"
            "@mozilla/firefox-devtools-mcp@latest"
            # Headless by default. Remove "--headless" to see the browser window.
            "--headless"
            "--firefox-path"
            "${lib.getExe pkgs.firefox}"
            "--profile-path"
            "${config.home.homeDirectory}/.mozilla/firefox/mcp-agent"
          ];
        };

      };

      odysseus = [
        (mkStdio "nixos" "${lib.getExe pkgs.mcp-nixos}" [ ] { })

        # context7 is remote (SSE/HTTP) — handled via odysseus UI

        (mkStdio "filesystem" "${lib.getExe pkgs.mcp-server-filesystem}" [
          "/home/helios/builds"
          "/home/helios/shared"
          "/home/helios/.config"
          "/home/helios/repos"
          "/var/opencode"
        ] { })

        (mkStdio "github" "${lib.getExe pkgs.github-mcp-server}" [ "stdio" "--read-only" ] { })

        (mkStdio "sequential-thinking" "${lib.getExe pkgs.mcp-server-sequential-thinking}" [ ] { })

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

    # Dedicated Firefox profile for the MCP agent.
    # Isolated from my real browsing data.
    home.file = {
      ".mozilla/firefox/mcp-agent/user.js".text = ''
        user_pref("browser.shell.checkDefaultBrowser", false);
        user_pref("browser.download.folderList", 2);
        user_pref("browser.download.manager.showWhenStarting", false);
        user_pref("dom.webnotifications.enabled", false);
        user_pref("signon.rememberSignons", false);
        user_pref("media.autoplay.default", 5);
        user_pref("browser.formfill.enable", false);
      '';
      ".mozilla/firefox/mcp-agent/.keep".text = "";
    };
  };
}

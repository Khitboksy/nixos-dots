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
  cfg = config.apps.ai.odysseus;
  odysseusPkg = pkgs.callPackage ./package.nix {
    odysseus-src = inputs.odysseus.outPath;
  };
  mcpServerList = pkgs.writeText "odysseus-mcp-servers" (
    builtins.toJSON config.apps.ai.mcps.odysseus
  );
  mcpSetup = pkgs.writeScript "odysseus-mcp-setup" ''
    #!${pkgs.runtimeShell}
    set -euo pipefail

    echo "Odysseus MCP Setup: waiting for Odysseus..."
    for i in $(seq 1 15); do
      if curl -sf http://127.0.0.1:7000/api/mcp/servers > /dev/null 2>&1; then
        break
      fi
      sleep 2
    done

    echo "Odysseus MCP Setup: fetching existing servers..."
    existing=$(
      curl -sf http://127.0.0.1:7000/api/mcp/servers \
        2>/dev/null \
      | ${pkgs.jq}/bin/jq -r '.[].name' 2>/dev/null \
      || echo ""
    )

    echo "Odysseus MCP Setup: registering MCP servers..."
    ${pkgs.jq}/bin/jq -c '.[]' ${mcpServerList} | while read -r server; do
      name=$(echo "$server" | ${pkgs.jq}/bin/jq -r '.name // empty')
      [ -z "$name" ] && continue

      if echo "$existing" | grep -qxF "$name"; then
        echo "  ''${name} already registered... skipping!"
        continue
      fi

      transport=$(echo "$server" | ${pkgs.jq}/bin/jq -r '.transport // "stdio"')
      command=$(echo "$server" | ${pkgs.jq}/bin/jq -r '.command // empty')
      args=$(echo "$server" | ${pkgs.jq}/bin/jq -c '.args // "[]"')
      env=$(echo "$server" | ${pkgs.jq}/bin/jq -c '.env // "{}"')

      echo "  registering ''${name}..."
      curl -sf -X POST http://127.0.0.1:7000/api/mcp/servers \
        -F "name=$name" \
        -F "transport=$transport" \
        -F "command=$command" \
        -F "args=$args" \
        -F "env=$env" \
        -F "is_enabled=true" \
        > /dev/null 2>&1 || true
    done

    echo "Odysseus MCP Setup: done!"
  '';
in
{
  options.apps.ai.odysseus = with types; {
    enable = mkBoolOpt false "Enable Odysseus AI Workspace (port 7000)";
  };

  config = mkIf cfg.enable {
    home.packages = [ odysseusPkg ];

    systemd.user.services = {

      odysseus = mkGraphicalService {

        Unit = {
          Description = "Odysseus AI Workspace";
          Documentation = "https://github.com/pewdiepie-archdaemon/odysseus";
        };

        Service = {
          Type = "simple";
          ExecStart = "${odysseusPkg}/bin/odysseus";
          Restart = "on-failure";
          RestartSec = 5;

          Environment = [
            "ODYSSEUS_HOST=127.0.0.1"
            "ODYSSEUS_PORT=7000"
          ];

          EnvironmentFile = [
            "${toString config.apps.ai.envFiles}/odysseus.env"
            "${pkgs.writeText "odysseus-settings" (builtins.readFile ./env)}"
          ];
        };
      };

      odysseus-mcp-oneshot = mkGraphicalService {

        Unit = {
          Description = "Register MCP servers for Odysseus";
          Documentation = "https://github.com/pewdiepie-archdaemon/odysseus";
          After = [ "odysseus.service" ];
          BindsTo = [ "odysseus.service" ];
        };

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${mcpSetup}";
        };

        Install.WantedBy = [ "default.target" ];
      };
    };
  };
}

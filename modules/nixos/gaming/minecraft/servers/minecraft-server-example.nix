{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
with lib.custom;

let
  # ─────────────────────────────────────────────────────────────────
  # NAME  —  CHANGE THIS when copying to create a new server variant
  #   Must match the filename (e.g. "vanilla" for vanilla.nix).
  #   This becomes the service name: minecraft-<name>
  #   and the option path:          gaming.minecraft.servers.<name>
  # ─────────────────────────────────────────────────────────────────
  srvName = "example";
  cfg = config.gaming.minecraft.servers.${srvName};
  stateDir = "/var/lib/minecraft-${srvName}";
in

{
  options.gaming.minecraft.servers.${srvName} = with types; {
    enable = mkBoolOpt false "Enable the Minecraft server: ${srvName}";

    serverSource = mkOption {
      type = str;
      default = "/PATH/TO/SERVER/FILES";
      example = "/home/user/minecraft-servers/${srvName}";
      description = ''
        Absolute path to the extracted server files directory.
        Must contain the server JAR, mods/, config/, etc.
      '';
    };

    jarFile = mkOption {
      type = str;
      default = "server.jar";
      example = "forge-1.12.2-14.23.5.2860.jar";
      description = "JAR filename to run (relative to the state directory).";
    };

    memory = mkOption {
      type = str;
      default = "2G";
      example = "4G";
      description = "Maximum heap memory (e.g. 2G, 4G, 6G).";
    };

    port = mkOption {
      type = port;
      default = 25565;
      description = "Server port for Minecraft connections.";
    };

    openFirewall = mkOption {
      type = bool;
      default = true;
      description = "Open the server port in the NixOS firewall.";
    };

    jvmOpts = mkOption {
      type = str;
      default = "";
      example = "-XX:+UseG1GC -XX:MaxGCPauseMillis=50";
      description = "Additional JVM flags beyond -Xmx and -Dfml flags.";
    };

    motd = mkOption {
      type = str;
      default = "A Minecraft Server";
      description = "Server message of the day.";
    };

    onlineMode = mkOption {
      type = bool;
      default = false;
      description = ''
        Verify Mojang accounts. Set to false for LAN play so friends
        can join without premium accounts.
      '';
    };

    maxPlayers = mkOption {
      type = ints.positive;
      default = 16;
      description = "Maximum number of players.";
    };

    difficulty = mkOption {
      type = types.enum [
        0
        1
        2
        3
      ];
      default = 2;
      description = "Game difficulty: 0=Peaceful, 1=Easy, 2=Normal, 3=Hard.";
    };

    pvp = mkOption {
      type = bool;
      default = true;
      description = "Enable player-vs-player combat.";
    };

    seed = mkOption {
      type = str;
      default = "";
      description = "World seed. Empty = random.";
    };

    whitelist = mkOption {
      type = bool;
      default = false;
      description = "Enable whitelist.";
    };
  };

  config = mkIf (config.gaming.minecraft.enable && cfg.enable) {

    # ── Firewall ──────────────────────────────────────────────────
    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

    # ── System user ───────────────────────────────────────────────
    users.users."minecraft-${srvName}" = {
      description = "Minecraft Server - ${srvName}";
      group = "minecraft-${srvName}";
      isSystemUser = true;
      home = stateDir;
      createHome = true;
    };

    users.groups."minecraft-${srvName}" = { };

    # ── Systemd service ───────────────────────────────────────────
    systemd.services."minecraft-${srvName}" = {
      description = "Minecraft Server - ${srvName}";
      after = [ "network.target" ];
      # wantedBy deliberately omitted — start manually via aliases or systemctl

      preStart =
        let
          setupScript = pkgs.writeShellScript "minecraft-${srvName}-setup" ''
            set -euo pipefail
            SRC="${cfg.serverSource}"
            DEST="${stateDir}"

            # Copy server files on first run
            if [ ! -d "$DEST" ] || [ -z "$(ls -A "$DEST" 2>/dev/null)" ]; then
                echo "Minecraft[${srvName}]: Copying server files from $SRC..."
                mkdir -p "$DEST"
                cp -r "$SRC/"* "$DEST/"
                chmod -R u+w "$DEST/"
            fi

            # Accept EULA
            if [ ! -f "$DEST/eula.txt" ]; then
                echo "Minecraft[${srvName}]: Accepting EULA..."
                { echo "eula=true"; } > "$DEST/eula.txt"
            fi

            chown -R "minecraft-${srvName}:minecraft-${srvName}" "$DEST"
          '';
        in
        "${setupScript}";

      serviceConfig = {
        ExecStart =
          let
            wrapper = pkgs.writeShellScript "minecraft-${srvName}-wrapper" ''
              set -euo pipefail
              WORK_DIR="${stateDir}"
              JAVA="${pkgs.jdk8}/bin/java"
              JAR="$WORK_DIR/${cfg.jarFile}"
              MEM="${cfg.memory}"
              JAVA_OPTS="-server -Xmx$MEM ${cfg.jvmOpts}"
              FIFO="$WORK_DIR/.stdin-fifo"

              cd "$WORK_DIR"

              rm -f "$FIFO"
              mkfifo "$FIFO"
              chmod o+w "$FIFO"

              # Start the pipeline FIRST (cat blocks on open-for-read).
              # Then we open the FIFO for writing below, which unblocks cat.
              cat "$FIFO" | $JAVA $JAVA_OPTS -jar "$JAR" nogui &
              PID=$!

              # Now open the FIFO for writing — cat is already waiting to read.
              # FD 3 stays open so cat never sees EOF.
              exec 3>"$FIFO"

              shutdown() {
                  echo "stop" > "$FIFO" 2>/dev/null || true
                  # Wait as long as Java needs — never force-kill (world corruption risk)
                  while kill -0 $PID 2>/dev/null; do
                      sleep 1
                  done
                  exec 3>&-
                  rm -f "$FIFO"
                  exit 0
              }
              trap shutdown SIGTERM SIGINT

              wait $PID
              EXIT_CODE=$?
              exec 3>&-
              rm -f "$FIFO"
              exit $EXIT_CODE
            '';
          in
          "${wrapper}";

        User = "minecraft-${srvName}";
        Group = "minecraft-${srvName}";
        Type = "simple";
        TimeoutStopSec = "infinity";
        Restart = "on-failure";
        RestartSec = "5s";
        WorkingDirectory = stateDir;
        StateDirectory = "minecraft-${srvName}";
        StateDirectoryMode = "0755";
        KillMode = "process";
        NoNewPrivileges = true;
        PrivateTmp = true;
      };
    };
  };
}

{
  lib,
  zenith,
  pkgs,
  config,
  ...
}:

with zenith.lib';

let
  srvName = "niri";
  cfg = config.gaming.minecraft.servers.${srvName};
  stateDir = "/var/lib/minecraft-${srvName}";
  versions = import ./versions.nix;

  # Fabric server launcher for 1.21.11 (loader 0.19.3 / installer 1.0.1).
  # On first run it downloads the vanilla server jar itself.
  launcherJar = pkgs.fetchurl {
    name = "fabric-server-launch.jar";
    url = "https://meta.fabricmc.net/v2/versions/loader/${versions.mcVersion}/${versions.fabricLoader.version}/${versions.fabricInstaller.version}/server/jar";
    hash = "sha256-Y0KF194g+t+rTLsoYDQZbgFjp9lcaT0JYgDhvsTR/6s=";
  };

  # Server-side mods defined in this file, installed into mods/ unconditionally.
  mods = [
    {
      name = "voicechat-fabric-${versions.mcVersion}-${versions.mods.voicechat.version}.jar";
      src = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/${versions.mods.voicechat.projectId}/versions/CN53keBo/voicechat-fabric-${versions.mcVersion}-${versions.mods.voicechat.version}.jar";
        hash = "sha256-yyO/37gJZxKIttn5rD/1hCzQLhOX3QBAviYKc9TjLGI=";
      };
    }
    {
      name = "lithium-fabric-${versions.mods.lithium.version}+mc${versions.mcVersion}.jar";
      src = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/${versions.mods.lithium.projectId}/versions/qvNsoO3l/lithium-fabric-${versions.mods.lithium.version}+mc${versions.mcVersion}.jar";
        hash = "sha256-hsG97K3MhVgBwvEMnlKJTSHJPjxSl8qDJwdN3RIeXFo=";
      };
    }
    {
      name = "fabric-api-${versions.mods.fabric-api.version}.jar";
      src = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/${versions.mods.fabric-api.projectId}/versions/6qAuTtLR/fabric-api-${
          builtins.replaceStrings [ "+" ] [ "%2B" ] versions.mods.fabric-api.version
        }.jar";
        hash = "sha256-vf9/1+IgCFz60v+bH0Dd5lNK4Lls83j5ejdLxUy57Q8=";
      };
    }
    {
      name = "floodgate-fabric-${versions.mods.floodgate.version}.jar";
      src = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/${versions.mods.floodgate.projectId}/versions/81EuNxeZ/Floodgate-Fabric-${versions.mods.floodgate.version}.jar";
        hash = "sha256-voH1QWv5GVm6EziJ3ERPjn5cx09/et73QiZlJ7l3foM=";
      };
    }
    {
      name = "RoughlyEnoughItems-${versions.mods.rei.version}-fabric.jar";
      src = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/${versions.mods.rei.projectId}/versions/QEiKPzyl/RoughlyEnoughItems-${versions.mods.rei.version}-fabric.jar";
        hash = "sha256-yUCjxhDe6xsGPWvMMnCf3t83FInVBLKe8FD+c4il+Ow=";
      };
    }
    {
      name = "architectury-${versions.mods.architectury.version}-fabric.jar";
      src = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/${versions.mods.architectury.projectId}/versions/uNdfrcQ8/architectury-${versions.mods.architectury.version}-fabric.jar";
        hash = "sha256-ZhOV1vC+8NOnlOLbdN9WAMc4e6b7lGsXIxWXcgGmZ8c=";
      };
    }
    {
      name = "cloth-config-${versions.mods.cloth-config.version}-fabric.jar";
      src = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/${versions.mods.cloth-config.projectId}/versions/xuX40TN5/cloth-config-${versions.mods.cloth-config.version}-fabric.jar";
        hash = "sha256-ikDITl7N5SWs+2xOE7gALaz8o++VNNf69ugEllb0I8g=";
      };
    }
    {
      name = "Jade-${versions.mcVersion}-Fabric-${versions.mods.jade.version}.jar";
      src = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/${versions.mods.jade.projectId}/versions/swJhAyak/Jade-${versions.mcVersion}-Fabric-${versions.mods.jade.version}.jar";
        hash = "sha256-vPGn9vnrMluJ1lvBW0GjX9yiwrBS6a93L/3NcFSNL8g=";
      };
    }
    {
      name = "appleskin-fabric-mc${versions.mcVersion}-${versions.mods.appleskin.version}.jar";
      src = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/${versions.mods.appleskin.projectId}/versions/59ti1rvg/appleskin-fabric-mc${versions.mcVersion}-${versions.mods.appleskin.version}.jar";
        hash = "sha256-BP6De+jxC7XmuZkjhZRGbFm9tkGlRRLxnx5nJB2IKuM=";
      };
    }
    {
      name = "ferritecore-${versions.mods.ferritecore.version}-fabric.jar";
      src = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/${versions.mods.ferritecore.projectId}/versions/Ii0gP3D8/ferritecore-${versions.mods.ferritecore.version}-fabric.jar";
        hash = "sha256-92vXYMv0goDMfEMYD1CJpGI1+iTZNKis89oEpmTCxxU=";
      };
    }
    {
      name = "server_waypoint-${versions.mods.server-waypoint.version}-fabric-mc${versions.mcVersion}.jar";
      src = pkgs.fetchurl {
        url = "https://cdn.modrinth.com/data/${versions.mods.server-waypoint.projectId}/versions/8iGACJOz/server_waypoint-${versions.mods.server-waypoint.version}-fabric-mc${versions.mcVersion}.jar";
        hash = "sha256-kakJxaN/iamCFwS2ILBLyiiW3m7V1Fwab+nMzGs53oM=";
      };
    }
    {
      name = "bluemap-${versions.addons.bluemap.version}-fabric.jar";
      src = pkgs.fetchurl {
        url = "https://github.com/BlueMap-Minecraft/BlueMap/releases/download/v${versions.addons.bluemap.version}/bluemap-${versions.addons.bluemap.version}-fabric.jar";
        hash = "sha256-3SRm6/5kh3bnoQMUi3+fzPhSx5lCPW7yT7J34sjiKCQ=";
      };
    }
  ];

  # Generates a full server.properties from module options
  serverProperties = ''
    # Niri Community Server - Generated by NixOS
    allow-flight=${if cfg.allowFlight then "true" else "false"}
    allow-nether=true
    broadcast-console-to-ops=true
    difficulty=${toString cfg.difficulty}
    enable-command-block=false
    enable-query=true
    enable-rcon=false
    force-gamemode=false
    gamemode=${toString cfg.gamemode}
    generate-structures=true
    generator-settings=
    hardcore=false
    level-name=${cfg.worldName}
    level-seed=${cfg.seed}
    level-type=${cfg.levelType}
    max-build-height=256
    max-players=${toString cfg.maxPlayers}
    max-tick-time=-1
    max-world-size=29999984
    motd=${cfg.motd}
    network-compression-threshold=256
    online-mode=${if cfg.onlineMode then "true" else "false"}
    op-permission-level=4
    player-idle-timeout=0
    prevent-proxy-connections=false
    pvp=${if cfg.pvp then "true" else "false"}
    query.port=${toString cfg.port}
    resource-pack=
    resource-pack-sha1=
    server-ip=0.0.0.0
    server-port=${toString cfg.port}
    snooper-enabled=true
    spawn-animals=true
    spawn-monsters=true
    spawn-npcs=true
    use-native-transport=true
    view-distance=${toString cfg.viewDistance}
    white-list=${if cfg.whitelist then "true" else "false"}
    enforce-secure-profile=false
  '';

  # Graceful-shutdown wrapper
  wrapperScript = pkgs.writeShellScript "minecraft-${srvName}-wrapper" ''
    set -euo pipefail

    WORK_DIR="${stateDir}"
    JAVA="${lib.getExe' pkgs.jdk21 "java"}"
    JAR="$WORK_DIR/${cfg.jarFile}"
    MEM="${cfg.memory}"
    JAVA_OPTS="-server -Xmx$MEM ${cfg.jvmOpts}"
    FIFO="$WORK_DIR/.stdin-fifo"

    cd "$WORK_DIR"
    chmod 755 "$WORK_DIR"

    rm -f "$FIFO"
    mkfifo "$FIFO"
    chmod 666 "$FIFO"

    # Start the pipeline FIRST (cat blocks on open-for-read).
    # Then we open the FIFO for writing below, which unblocks cat.
    cat "$FIFO" | $JAVA $JAVA_OPTS -jar "$JAR" nogui &
    PID=$!

    # Now open the FIFO for writing. cat is already waiting to read.
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

  # Keeps state directory at 755 so mc-console/mc-cmd can reach the FIFO.
  # Something (likely the server itself) resets it to 700 periodically.
  chmodLoopScript = pkgs.writeShellScript "minecraft-${srvName}-chmod-loop" ''
    while systemctl is-active --quiet "minecraft-${srvName}"; do
      chmod 755 "${stateDir}" 2>/dev/null || true
      sleep 60
    done
  '';

  setupScript = pkgs.writeShellScript "minecraft-${srvName}-setup" ''
    set -euo pipefail

    DEST="${stateDir}"

    # Create the state directory on first run
    if [ ! -d "$DEST" ] || [ -z "$(ls -A "$DEST" 2>/dev/null)" ]; then
        echo "Minecraft[${srvName}]: Creating state directory..."
        mkdir -p "$DEST"
    fi

    # Install the Fabric launcher into the state dir if missing
    if [ ! -f "$DEST/${cfg.jarFile}" ]; then
        echo "Minecraft[${srvName}]: Installing Fabric launcher..."
        cp "${cfg.launcher}" "$DEST/${cfg.jarFile}"
    fi

    # Install the server-side mods defined in this module
    mkdir -p "$DEST/mods"
    ${lib.concatMapStringsSep "\n" (m: ''
      if [ ! -f "$DEST/mods/${m.name}" ]; then
          echo "Minecraft[${srvName}]: Installing ${m.name}..."
          cp "${m.src}" "$DEST/mods/${m.name}"
      fi
    '') mods}

    # Install extra mods from the `mods` option (additive, store paths)
    ${lib.concatMapStringsSep "\n" (p: ''
      _m="$(basename ${p})"
      if [ ! -f "$DEST/mods/$_m" ]; then
          echo "Minecraft[${srvName}]: Installing extra mod $_m..."
          cp "${p}" "$DEST/mods/$_m"
      fi
    '') cfg.mods}

    # Accept Minecraft EULA
    if [ ! -f "$DEST/eula.txt" ]; then
        echo "Minecraft[${srvName}]: Accepting EULA..."
        {
            echo "# By setting eula=true you are agreeing to the Minecraft EULA"
            echo "# https://aka.ms/MinecraftEULA"
            echo "eula=true"
        } > "$DEST/eula.txt"
    fi

    # Write a fresh server.properties every time (keeps in sync with config)
    echo "Minecraft[${srvName}]: Writing server.properties..."
    cat > "$DEST/server.properties" << 'PROP'
    ${serverProperties}
    PROP

    # Write the Simple Voice Chat server config (pins the UDP port)
    if [ "${if cfg.voiceChat.enable then "true" else "false"}" = "true" ]; then
        echo "Minecraft[${srvName}]: Writing voicechat server config..."
        mkdir -p "$DEST/config/voicechat"
        echo "port=${toString cfg.voiceChat.port}" > "$DEST/config/voicechat/voicechat-server.properties"
        ${lib.optionalString (cfg.voiceChat.host != "")
          ''echo "voice_host=${cfg.voiceChat.host}" >> "$DEST/config/voicechat/voicechat-server.properties"''
        }
    fi

    # Write the server_waypoint config declaratively (permission lockdown).
    # Written fresh each start so it stays in sync with module options.
    # waypoints/*.json are user data and are NEVER overwritten here.
    if [ "${if cfg.serverWaypoint.enable then "true" else "false"}" = "true" ]; then
        echo "Minecraft[${srvName}]: Writing server_waypoint config..."
        mkdir -p "$DEST/config/server_waypoint/waypoints"
        cat > "$DEST/config/server_waypoint/config.json" << 'SERVER_WAYPOINT'
    {
      "serverId": ${toString cfg.serverWaypoint.serverId},
      "CommandPermission": {
        "add": 0,
        "edit": 2,
        "remove": 2,
        "tp": 2,
        "reload": 2
      },
      "Features": {
        "addWaypointFromChatSharing": true,
        "sendXaerosWorldId": true
      }
    }
    SERVER_WAYPOINT
    fi

    # Write the BlueMap config declaratively (web port + 2D flat-view only).
    # Written fresh each start so it stays in sync with module options.
    if [ "${if cfg.bluemap.enable then "true" else "false"}" = "true" ]; then
        echo "Minecraft[${srvName}]: Writing bluemap config..."
        mkdir -p "$DEST/config/bluemap/maps"
        cat > "$DEST/config/bluemap/core.conf" << 'BLUEMAP_CORE'
    accept-download: true
    BLUEMAP_CORE
        cat > "$DEST/config/bluemap/webserver.conf" << 'BLUEMAP_WEBSERVER'
    port: ${toString cfg.bluemap.port}
    BLUEMAP_WEBSERVER
        # Per-dimension maps. Flat view + hires only (no 3D perspective/free-flight).
        # The world save lives at $DEST/${cfg.worldName}; BlueMap reads the level
        # through the versioned dimension subfolder automatically.
        mkdir -p "$DEST/config/bluemap/maps"
        cat > "$DEST/config/bluemap/maps/world.conf" << 'BLUEMAP_OVERWORLD'
    world: "${stateDir}/${cfg.worldName}"
    dimension: "minecraft:overworld"
    name: "Overworld"
    sorting: 0
    enable-perspective-view: false
    enable-free-flight-view: false
    BLUEMAP_OVERWORLD
        cat > "$DEST/config/bluemap/maps/world_nether.conf" << 'BLUEMAP_NETHER'
    world: "${stateDir}/${cfg.worldName}"
    dimension: "minecraft:the_nether"
    name: "The Nether"
    sorting: 100
    enable-perspective-view: false
    enable-free-flight-view: false
    render-mask: [
      {
        # Remove the Nether's bedrock ceiling (y 90-127) for a clean top-down view.
        subtract: true
        min-y: 90
        max-y: 127
      }
    ]
    BLUEMAP_NETHER
        cat > "$DEST/config/bluemap/maps/world_the_end.conf" << 'BLUEMAP_END'
    world: "${stateDir}/${cfg.worldName}"
    dimension: "minecraft:the_end"
    name: "The End"
    sorting: 200
    enable-perspective-view: false
    enable-free-flight-view: false
    BLUEMAP_END

        # Bake server_waypoint waypoints into each matching map-config as a
        # BlueMap marker-set (poi markers). Snapshot-on-restart: refreshed every
        # boot; not live mid-session. Guards keep a missing/malformed waypoint
        # file from failing ExecStartPre (which would block boot).
        if [ "${if cfg.serverWaypoint.enable then "true" else "false"}" = "true" ]; then
            JQ="${lib.getExe pkgs.jq}"
            for spec in "world.conf minecraft\$overworld" "world_nether.conf minecraft\$the_nether" "world_the_end.conf minecraft\$the_end"; do
                set -- $spec
                _mapconf="$1"
                _wfname="$2"
                if [ -f "$DEST/config/server_waypoint/waypoints/$_wfname.json" ] && [ -f "$DEST/config/bluemap/maps/$_mapconf" ]; then
                    echo "Minecraft[${srvName}]: Adding waypoint markers to bluemap $_mapconf..."
                    {
                        echo ""
                        echo "marker-sets: {"
                        echo "  server-waypoints {"
                        echo "    label: \"Server Waypoints\""
                        echo "    toggleable: true"
                        echo "    default-hidden: false"
                        echo "    sorting: 0"
                        echo "    markers: {"
                        "$JQ" -r '
                            .[] | . as $l | $l.waypoints | to_entries[] |
                            "      " + (($l.list_name | gsub("[^A-Za-z0-9_]"; "_")) + "_" + (.key | tostring)) + ": {",
                            "        type: \"poi\"",
                            "        position: { x: " + (.value.pos[0] | tostring) + ", y: " + (.value.pos[1] | tostring) + ", z: " + (.value.pos[2] | tostring) + " }",
                            "        label: \"" + (.value.name | gsub("[\"\\\\]"; "")) + "\"",
                            "        anchor: { x: 25, y: 45 }",
                            "        sorting: 0",
                            "        listed: true",
                            "        min-distance: 0",
                            "        max-distance: 10000000",
                            "      }"
                        ' "$DEST/config/server_waypoint/waypoints/$_wfname.json" || true
                        echo "    }"
                        echo "  }"
                        echo "}"
                    } >> "$DEST/config/bluemap/maps/$_mapconf"
                fi
            done
        fi
    fi

    # Ensure the state dir is traversable by the helios user (for mc-console, mc-cmd, mc-backup).
    chmod 755 "$DEST"
    chown -R "minecraft-${srvName}:minecraft-${srvName}" "$DEST"
  '';
in

{
  imports = [ ./viaproxy.nix ];

  options.gaming.minecraft.servers.${srvName} = with lib.types; {
    enable = mkBoolOpt false "Enable the Niri community Minecraft server (Fabric 1.21.11 + Simple Voice Chat).";

    launcher = mkStringOpt launcherJar.outPath "Path to the Fabric server launcher jar (copied into the state dir on first use).";

    serverSource = mkStringOpt' "";

    jarFile = mkStringOpt' "fabric-server-launch.jar";

    memory = mkStringOpt' "4G";

    jvmOpts = mkStringOpt' "-XX:+UseG1GC -Dlog4j2.formatMsgNoLookups=true";

    port = mkOpt' port 25567;

    openFirewall = mkBoolOpt' true;

    motd = mkStringOpt' "Niri Community Server";

    maxPlayers = mkOpt' ints.positive 20;

    difficulty = mkEnumOpt' [ 0 1 2 3 ] 2;

    gamemode = mkEnumOpt' [ 0 1 2 3 ] 0;

    onlineMode = mkBoolOpt' true;

    whitelist = mkBoolOpt' false;

    pvp = mkBoolOpt' true;

    allowFlight = mkBoolOpt' false;

    seed = mkStringOpt "" "Leave blank for random";

    worldName = mkStringOpt' "world";

    levelType = mkStringOpt' "DEFAULT";

    viewDistance = mkOpt' (ints.between 3 32) 10;

    # Extra server-side Fabric mod jars (store paths) installed into mods/, added
    # on top of the base mods defined inside the module.
    mods =
      mkStringListOpt [ ]
        "Extra server-side Fabric mod jar store paths copied into mods/ (additive to the in-module base mods).";

    voiceChat = {
      enable = mkBoolOpt' true;
      port = mkOpt' port 24454;
      host = mkStringOpt' "";
    };

    bluemap = {
      enable = mkBoolOpt' false;
      port = mkOpt' port 8100;
    };

    # server_waypoint: global waypoints synced to Xaero's clients.
    # Permission lockdown: everyone can add (/wp add); only ops can edit,
    # remove, or teleport (/wp edit|remove|tp|reload).
    serverWaypoint = {
      enable = mkBoolOpt' true;
      # Pinned stable so the per-server waypoint id doesn't randomize every
      # boot (that would confuse the Xaero's sync clients).
      serverId = mkOpt' ints.positive 1787329663;
    };
  };

  config = lib.mkIf cfg.enable {

    # Version registry JSON for mc-modcheck shell function
    environment.etc."mc-modcheck.json".source = pkgs.writeText "mc-modcheck.json" (
      builtins.toJSON {
        inherit (versions)
          mcVersion
          fabricLoader
          fabricInstaller
          mods
          addons
          ;
      }
    );

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall (
      [ cfg.port ] ++ lib.optionals cfg.bluemap.enable [ cfg.bluemap.port ]
    );

    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall (
      lib.optionals cfg.voiceChat.enable [ cfg.voiceChat.port ]
    );

    users.users."minecraft-${srvName}" = {
      description = "Minecraft Server - Niri";
      group = "minecraft-${srvName}";
      isSystemUser = true;
      home = stateDir;
      createHome = true;
    };

    users.groups."minecraft-${srvName}" = { };

    systemd.services."minecraft-${srvName}" = {
      description = "Niri Minecraft Server (Fabric 1.21.11)";
      after = [ "network.target" ];

      serviceConfig = {
        ExecStartPre = [ "+${setupScript}" ];
        ExecStart = "${wrapperScript}";
        ExecStartPost = [ "+${chmodLoopScript}" ];
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

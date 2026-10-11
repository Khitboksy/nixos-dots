{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.gaming.minecraft.servers.niri;
  stateDir = "/var/lib/viaproxy-niri";
  versions = import ./versions.nix;

  viaproxyJar = pkgs.fetchurl {
    name = "ViaProxy-${versions.addons.viaproxy.version}.jar";
    url = "https://github.com/ViaVersion/ViaProxy/releases/download/v${versions.addons.viaproxy.version}/ViaProxy-${versions.addons.viaproxy.version}.jar";
    hash = "sha256-Ms6a2HGusDKGgjwp2iYuvXWZKGTnhX2yg/EDUlx/wMs=";
  };

  geyserViaProxyJar = pkgs.fetchurl {
    name = "Geyser-ViaProxy-${versions.addons.geyser-viaproxy.version}.jar";
    url = "https://download.geysermc.org/v2/projects/geyser/versions/${versions.addons.geyser-viaproxy.version}/builds/latest/downloads/viaproxy";
    hash = "sha256-ZwwnY9ICQ4H2q3OGvCHDLA3haELRW+fP+SLynlDnY74=";
  };

  # Niri's Floodgate key.pem path
  floodgateKey = "/var/lib/minecraft-niri/config/floodgate/key.pem";

  # ViaProxy config — headless CLI mode for Bedrock translation only
  viaproxyConfig = ''
    # ViaProxy configuration for Niri Bedrock support
    # DO NOT MODIFY — managed by NixOS

    # ViaProxy listens for Bedrock connections on this address.
    bind-address: "0.0.0.0:19132"

    # Forward translated connections to the Niri Minecraft server.
    target-address: "127.0.0.1:${toString cfg.port}"

    # Auto-detect target version from the backend server.
    target-version: "auto"

    # Connect timeout in milliseconds.
    connect-timeout: 8000

    # Offline mode — Floodgate handles authentication.
    proxy-online-mode: false
    auth-method: "none"

    # Enable Simple Voice Chat passthrough.
    simple-voice-chat-support: true

    # Bedrock clients don't use chat signing.
    chat-signing: false

    # Rewrite handshake to look like a direct connection.
    rewrite-handshake-packet: true

    # Suppress protocol translation errors (prevents disconnects on minor issues).
    ignore-protocol-translation-errors: false

    # Silently accept resource packs from server without forwarding to Bedrock client.
    fake-accept-resource-packs: true
  '';

  # Geyser-ViaProxy config — Bedrock protocol translation
  geyserConfig = ''
    # Geyser config for ViaProxy — managed by NixOS
    update-checker: false
    notify-on-new-bedrock-update: false

    bedrock:
      address: 0.0.0.0
      port: 19132
      clone-remote-port: false

    # remote section is auto-configured by ViaProxy.
    # auth-type is auto-detected from key.pem presence.

    motd:
      passthrough-motd: true
      passthrough-player-counts: true
      primary-motd: "Niri Community Server"
      secondary-motd: "Java + Bedrock"

    gameplay:
      server-name: "Niri"
      show-coordinates: true
      command-suggestions: true
      emotes-enabled: true

    advanced:
      floodgate-key-file: key.pem
  '';

  # Per-start setup: writes configs + installs plugins into the state dir.
  setupScript = pkgs.writeShellScript "viaproxy-niri-setup" ''
    set -euo pipefail

    DEST="${stateDir}"

    # Create the state directory
    mkdir -p "$DEST"

    # Write ViaProxy config fresh each start
    echo "ViaProxy[niri]: Writing viaproxy config..."
    cat > "$DEST/viaproxy.yml" << 'VIAPROXY'
    ${viaproxyConfig}
    VIAPROXY

    # Install Geyser-ViaProxy plugin (jar goes at top-level plugins/, config in subdirectory)
    mkdir -p "$DEST/plugins/Geyser"
    cp "${geyserViaProxyJar}" "$DEST/plugins/Geyser-ViaProxy.jar"

    # Write Geyser config fresh each start
    echo "ViaProxy[niri]: Writing Geyser config..."
    cat > "$DEST/plugins/Geyser/config.yml" << 'GEYSER'
    ${geyserConfig}
    GEYSER

    # Copy Floodgate key.pem from niri's Floodgate plugin
    if [ -f "${floodgateKey}" ]; then
        echo "ViaProxy[niri]: Copying Floodgate key..."
        cp "${floodgateKey}" "$DEST/plugins/Geyser/key.pem"
    else
        echo "ViaProxy[niri]: WARNING — Floodgate key.pem not found at ${floodgateKey}"
        echo "ViaProxy[niri]: Bedrock players will not be able to connect until Floodgate is initialized on niri."
    fi

    # Ensure correct ownership
    chown -R "minecraft-niri:minecraft-niri" "$DEST"
  '';
in

{
  config = lib.mkIf cfg.enable {

    systemd.services."viaproxy-niri" = {
      description = "ViaProxy for Niri Bedrock support";
      after = [ "minecraft-niri.service" ];
      requires = [ "minecraft-niri.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStartPre = [ "+${setupScript}" ];
        ExecStart = "${lib.getExe' pkgs.jdk21 "java"} -server -Xmx1G -jar ${viaproxyJar} cli";
        WorkingDirectory = stateDir;
        User = "minecraft-niri";
        Group = "minecraft-niri";
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";
        StateDirectory = "viaproxy-niri";
        StateDirectoryMode = "0755";
        NoNewPrivileges = true;
        PrivateTmp = true;
      };
    };

    # ViaProxy listens on UDP 19132 for Bedrock clients
    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [ 19132 ];
  };
}

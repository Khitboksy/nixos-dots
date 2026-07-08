{ pkgs, lib }:

with lib;
with lib.custom;
with pkgs;

{
  mc-start = ''
    if test (count $argv) -eq 0
      printf "Usage: mc-start <server-name>\n"
      return 1
    end
    set server $argv[1]

    # ── Check if already running ──────────────────────────────────────
    if systemctl is-active --quiet "minecraft-$server"
      printf "${colors.yellow.ansi}$server is already running.${ansiReset}\n"
      return 0
    end

    set -l start_ts (date +%s)

    # ── Stage 1: Start and wait for properties ────────────────────────
    printf "${colors.green.ansi}->${ansiReset} ${colors.peach.ansi}Starting${ansiReset} ${colors.blue.ansi}$server${ansiReset} ${colors.text.ansi}...${ansiReset}\n"
    sudo systemctl start "minecraft-$server"

    set -l waited 0
    while test $waited -lt 30
      sleep 1
      set waited (math $waited + 1)
      if journalctl -u "minecraft-$server" --since=@"$start_ts" --no-pager 2>/dev/null | grep -q "Writing server.properties"
        break
      end
      if not systemctl is-active --quiet "minecraft-$server"
        printf "${colors.red.ansi}$server failed to start!${ansiReset}\n"
        journalctl -u "minecraft-$server" -n 20 --no-pager 2>/dev/null
        return 1
      end
    end

    # ── Stage 2: Wait for startup tick ────────────────────────────────
    printf "${colors.green.ansi}->${ansiReset} ${colors.peach.ansi}Waiting for startup to complete${ansiReset} ${colors.text.ansi}...${ansiReset}\n"
    set -l timeout 180
    set -l waited 0

    while test $waited -lt $timeout
      sleep 2
      set waited (math $waited + 2)

      if journalctl -u "minecraft-$server" --since=@"$start_ts" --no-pager 2>/dev/null | grep -q "Hello from the async scope|Hello from the server tick"
        printf "${colors.green.ansi}$server started successfully!${ansiReset}\n"
        return 0
      end

      if not systemctl is-active --quiet "minecraft-$server"
        printf "${colors.red.ansi}$server failed to start!${ansiReset}\n"
        journalctl -u "minecraft-$server" -n 20 --no-pager 2>/dev/null
        return 1
      end
    end

    printf "${colors.red.ansi}⚠ Timed out waiting for $server to start ($timeout seconds)${ansiReset}\n"
    return 1
  '';
}

{ pkgs, lib }:

with lib;
with lib.custom;
with pkgs;

{
  mc-restart = ''
    if test (count $argv) -eq 0
      printf "Usage: mc-restart <server-name>\n"
      return 1
    end
    set server $argv[1]

    # ── Check current state ──────────────────────────────────────────
    set -l was_active (systemctl is-active --quiet "minecraft-$server"; and echo 1; or echo 0)

    # ── Shutdown phase ────────────────────────────────────────────────
    if test $was_active -eq 1
      set -l stop_ts (date +%s)
      sudo systemctl stop "minecraft-$server" &
      set -l stop_pid $last_pid

      # Stage 1: Wait for "Stopping server" from Minecraft
      set -l waited 0
      while test $waited -lt 30
        sleep 1
        set waited (math $waited + 1)
        if journalctl -u "minecraft-$server" --since=@"$stop_ts" --no-pager 2>/dev/null | grep -q "Stopping server"
          printf "${hexToAnsi colors.green.hex}->${ansiReset} ${hexToAnsi colors.peach.hex}Stopping${ansiReset} ${hexToAnsi colors.blue.hex}$server${ansiReset} ${hexToAnsi colors.text.hex}...${ansiReset}\n"
          break
        end
        # Already stopped before we saw the message
        if not systemctl is-active --quiet "minecraft-$server"
          break
        end
      end

      # Stage 2: Wait for save activity, then 5s idle
      set -l save_time 0
      set -l save_printed 0
      set -l waited 0
      while test $waited -lt 60
        sleep 1
        set waited (math $waited + 1)
        if journalctl -u "minecraft-$server" --since=@"$stop_ts" --no-pager 2>/dev/null | grep -q "Saving players|Saving worlds|Saving chunks"
          set save_time (date +%s)
          if test $save_printed -eq 0
            printf "${hexToAnsi colors.green.hex}->${ansiReset} ${hexToAnsi colors.peach.hex}Saving Level${ansiReset} ${hexToAnsi colors.text.hex}...${ansiReset}\n"
            set save_printed 1
          end
        end
        # 5 seconds since last save → save phase done
        if test $save_time -ne 0; and test (math (date +%s) - $save_time) -ge 5
          break
        end
        # Server already gone
        if not systemctl is-active --quiet "minecraft-$server"
          break
        end
      end

      # Stage 3: Wait for stop to fully complete
      printf "${hexToAnsi colors.green.hex}->${ansiReset} ${hexToAnsi colors.peach.hex}Waiting for server${ansiReset} ${hexToAnsi colors.text.hex}...${ansiReset}\n"
      wait $stop_pid 2>/dev/null
    end

    # Stage 4: Server stopped
    printf "${hexToAnsi colors.green.hex}$server Stopped.${ansiReset}\n"

    # ── Startup phase ─────────────────────────────────────────────────
    set -l start_ts (date +%s)

    # Stage 5: Start and wait for properties to be written
    printf "${hexToAnsi colors.green.hex}->${ansiReset} ${hexToAnsi colors.peach.hex}Starting${ansiReset} ${hexToAnsi colors.blue.hex}$server${ansiReset} ${hexToAnsi colors.text.hex}...${ansiReset}\n"
    sudo systemctl start "minecraft-$server"

    set -l waited 0
    while test $waited -lt 30
      sleep 1
      set waited (math $waited + 1)
      if journalctl -u "minecraft-$server" --since=@"$start_ts" --no-pager 2>/dev/null | grep -q "Writing server.properties"
        break
      end
    end

    # Stage 6: Wait for startup tick
    printf "${hexToAnsi colors.green.hex}->${ansiReset} ${hexToAnsi colors.peach.hex}Waiting for startup to complete${ansiReset} ${hexToAnsi colors.text.hex}...${ansiReset}\n"
    set -l timeout 180
    set -l waited 0

    while test $waited -lt $timeout
      sleep 2
      set waited (math $waited + 2)

      if journalctl -u "minecraft-$server" --since=@"$start_ts" --no-pager 2>/dev/null | grep -q "Hello from the async scope|Hello from the server tick"
        printf "${hexToAnsi colors.green.hex}$server started successfully!${ansiReset}\n"
        return 0
      end

      if not systemctl is-active --quiet "minecraft-$server"
        printf "${hexToAnsi colors.red.hex}$server failed to start!${ansiReset}\n"
        journalctl -u "minecraft-$server" -n 20 --no-pager 2>/dev/null
        return 1
      end
    end

    printf "${hexToAnsi colors.red.hex}⚠ Timed out waiting for $server to start ($timeout seconds)${ansiReset}\n"
    return 1
  '';
}

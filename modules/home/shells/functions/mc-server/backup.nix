{ pkgs, lib }:

with lib;
with lib.custom;
with pkgs;

{
  mc-backup = ''
    if test (count $argv) -lt 2
      printf "Usage: mc-backup ${hexToAnsi colors.blue.hex}<server>${ansiReset} {${hexToAnsi colors.green.hex}list${ansiReset}|${hexToAnsi colors.green.hex}run${ansiReset}|${hexToAnsi colors.green.hex}restore${ansiReset}}\n"
      return 1
    end
    set -l server $argv[1]
    set -l flag $argv[2]
    set -l src_dir "/var/lib/minecraft-$server"
    set -l backup_dir "/mnt/nix-data/Games/minecraft/backups/$server"
    set -l fifo "$src_dir/.stdin-fifo"

    switch "$flag"
      case list
        ls "$backup_dir"

      case run
        set -l was_running 0
        if systemctl is-active --quiet "minecraft-$server"
          set was_running 1
          if test -p "$fifo"
            printf "${hexToAnsi colors.green.hex}->${ansiReset} ${hexToAnsi colors.peach.hex}Freezing world${ansiReset} ${hexToAnsi colors.text.hex}...${ansiReset}\n"
            echo "save-off" > "$fifo"
            sleep 1
            printf "${hexToAnsi colors.green.hex}->${ansiReset} ${hexToAnsi colors.peach.hex}Flushing chunks to disk${ansiReset} ${hexToAnsi colors.text.hex}...${ansiReset}\n"
            echo "save-all" > "$fifo"
            # Give it time to finish flushing
            sleep 5
          else
            printf "${hexToAnsi colors.yellow.hex}Warning:${ansiReset} ${hexToAnsi colors.text.hex}Server running but FIFO not found — backing up without save-off/save-all.${ansiReset}\n"
          end
        end

        mkdir -p "$backup_dir"
        set -l timestamp (date +%Y-%m-%d_%H%M%S)
        set -l count 1
        set -l files "$backup_dir"/*.tar.gz
        if test -f "$files[1]"
          set count (math (count $files) + 1)
        end
        set -l archive "$backup_dir/$server-$count-$timestamp.tar.gz"

        printf "${hexToAnsi colors.green.hex}->${ansiReset} ${hexToAnsi colors.peach.hex}Backing up${ansiReset} ${hexToAnsi colors.blue.hex}$server${ansiReset} ${hexToAnsi colors.text.hex}...${ansiReset}\n"

        sudo tar -czf "$archive" \
          --exclude='.stdin-fifo' \
          -C "$src_dir" .

        # Re-enable saving if we froze it
        if test "$was_running" -eq 1; and test -p "$fifo"
          printf "${hexToAnsi colors.green.hex}->${ansiReset} ${hexToAnsi colors.peach.hex}Unfreezing world${ansiReset} ${hexToAnsi colors.text.hex}...${ansiReset}\n"
          echo "save-on" > "$fifo"
        end

        set -l size (du -h "$archive" | cut -f1)
        printf "${hexToAnsi colors.green.hex}✓${ansiReset} ${hexToAnsi colors.text.hex}Backup saved:${ansiReset} ${hexToAnsi colors.blue.hex}%s${ansiReset} ${hexToAnsi colors.text.hex}(%s)${ansiReset}\n" (basename "$archive") "$size"

      case restore
        if test (count $argv) -lt 3
          printf "${hexToAnsi colors.red.hex}Error:${ansiReset} ${hexToAnsi colors.text.hex}Specify an archive name to restore. Use${ansiReset}\n"
          printf "  ${hexToAnsi colors.green.hex}mc-backup $server list${ansiReset} ${hexToAnsi colors.text.hex}to see available backups.${ansiReset}\n"
          return 1
        end
        set -l restore_from $argv[3]
        set -l restore_path "$backup_dir/$restore_from"

        if not test -f "$restore_path"
          printf "${hexToAnsi colors.red.hex}Error:${ansiReset} ${hexToAnsi colors.text.hex}Archive${ansiReset} ${hexToAnsi colors.blue.hex}$restore_from${ansiReset} ${hexToAnsi colors.text.hex}not found in${ansiReset}\n"
          printf "  ${hexToAnsi colors.peach.hex}$backup_dir${ansiReset}\n"
          return 1
        end

        # Server must be stopped for restore
        if systemctl is-active --quiet "minecraft-$server"
          printf "${hexToAnsi colors.red.hex}Error:${ansiReset} ${hexToAnsi colors.blue.hex}$server${ansiReset} ${hexToAnsi colors.text.hex}is running. Stop it first:${ansiReset}\n"
          printf "  ${hexToAnsi colors.green.hex}mc-stop $server${ansiReset}\n"
          return 1
        end

        # Confirm — destructive operation
        printf "${hexToAnsi colors.yellow.hex}⚠ Warning:${ansiReset} ${hexToAnsi colors.text.hex}This will overwrite ALL data for${ansiReset}\n"
        printf "  ${hexToAnsi colors.blue.hex}$server${ansiReset}\n"
        printf "${hexToAnsi colors.text.hex}with the contents of:${ansiReset}\n"
        printf "  ${hexToAnsi colors.blue.hex}$restore_from${ansiReset}\n"
        printf "${hexToAnsi colors.text.hex}Proceed?${ansiReset} ${hexToAnsi colors.peach.hex}[y/N]${ansiReset} "
        read -l confirm
        if test "$confirm" != "y" -a "$confirm" != "Y"
          printf "${hexToAnsi colors.text.hex}Restore cancelled.${ansiReset}\n"
          return 0
        end

        printf "${hexToAnsi colors.green.hex}->${ansiReset} ${hexToAnsi colors.peach.hex}Restoring${ansiReset} ${hexToAnsi colors.blue.hex}$server${ansiReset} ${hexToAnsi colors.text.hex}from backup...${ansiReset}\n"

        # Ensure runtime dir exists, then wipe everything except the FIFO
        sudo mkdir -p "$src_dir"
        sudo find "$src_dir" -mindepth 1 -not -name '.stdin-fifo' -delete

        # Extract the backup
        sudo tar -xzf "$restore_path" -C "$src_dir"

        # Fix ownership
        sudo chown -R "minecraft-$server:minecraft-$server" "$src_dir"

        printf "${hexToAnsi colors.green.hex}✓${ansiReset} ${hexToAnsi colors.text.hex}Restore complete. Start the server:${ansiReset}\n"
        printf "  ${hexToAnsi colors.green.hex}mc-start $server${ansiReset}\n"

      case '*'
        printf "${hexToAnsi colors.red.hex}Error:${ansiReset} ${hexToAnsi colors.text.hex}Unknown flag '${ansiReset}${hexToAnsi colors.peach.hex}$flag${ansiReset}${hexToAnsi colors.text.hex}'. Use${ansiReset}\n"
        printf "  ${hexToAnsi colors.green.hex}mc-backup $server {list|run|restore}${ansiReset}\n"
        return 1
    end
  '';
}

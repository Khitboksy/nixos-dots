{ pkgs, lib }:

with lib;
with lib.custom;

let
  openssh = getExe pkgs.openssh;
  rsync = getExe pkgs.rsync;
in

{
  mc-backup = ''
    if test (count $argv) -lt 2
      printf "Usage: mc-backup ${colors.blue.ansi}<server>${ansiReset} {${colors.green.ansi}list${ansiReset}|${colors.green.ansi}run${ansiReset}|${colors.green.ansi}restore${ansiReset}}\n"
      return 1
    end
    set -l server $argv[1]
    set -l flag $argv[2]
    set -l src_dir "/var/lib/minecraft-$server"
    set -l backup_dir "/home/helios/minecraft/backups/$server"
    set -l fifo "$src_dir/.stdin-fifo"
    set -l remote_user "helios"
    set -l remote_host "helios"
    set -l remote_backup_dir "/mnt/nix-data/Games/minecraft/backups/$server/"
    set -l ssh_key "$HOME/.ssh/id_ed25519_terra_exit"

    switch "$flag"
      case list
        ${openssh} -i $ssh_key -o StrictHostKeyChecking=accept-new "$remote_user@$remote_host" "ls -1 $remote_backup_dir" 2>/dev/null
        if test $status -ne 0
          printf "${colors.yellow.ansi}⚠${ansiReset} ${colors.text.ansi}Could not reach $remote_host. Checking local backups...${ansiReset}\n"
          ls "$backup_dir" 2>/dev/null; or printf "${colors.text.ansi}No backups found.${ansiReset}\n"
        end

      case run
        set -l was_running 0
        if systemctl is-active --quiet "minecraft-$server"
          set was_running 1
          if test -p "$fifo"
            printf "${colors.green.ansi}->${ansiReset} ${colors.peach.ansi}Freezing world${ansiReset} ${colors.text.ansi}...${ansiReset}\n"
            echo "save-off" > "$fifo"
            sleep 1
            printf "${colors.green.ansi}->${ansiReset} ${colors.peach.ansi}Flushing chunks to disk${ansiReset} ${colors.text.ansi}...${ansiReset}\n"
            echo "save-all" > "$fifo"
            # Give it time to finish flushing
            sleep 5
          else
            printf "${colors.yellow.ansi}Warning:${ansiReset} ${colors.text.ansi}Server running but FIFO not found — backing up without save-off/save-all.${ansiReset}\n"
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

        printf "${colors.green.ansi}->${ansiReset} ${colors.peach.ansi}Backing up${ansiReset} ${colors.blue.ansi}$server${ansiReset} ${colors.text.ansi}...${ansiReset}\n"

        sudo tar -czf "$archive" \
          --exclude='.stdin-fifo' \
          -C "$src_dir" .

        # Re-enable saving if we froze it
        if test "$was_running" -eq 1; and test -p "$fifo"
          printf "${colors.green.ansi}->${ansiReset} ${colors.peach.ansi}Unfreezing world${ansiReset} ${colors.text.ansi}...${ansiReset}\n"
          echo "save-on" > "$fifo"
        end

        # Push off-machine backup to helios
        printf "${colors.green.ansi}->${ansiReset} ${colors.peach.ansi}Pushing backup to${ansiReset} ${colors.blue.ansi}%s${ansiReset} ${colors.text.ansi}...${ansiReset}\n" "$remote_host"
        ${rsync} -az -e "${openssh} -i $ssh_key -o StrictHostKeyChecking=accept-new" "$archive" "$remote_user@$remote_host:$remote_backup_dir"
        if test $status -eq 0
          printf "${colors.green.ansi}✓${ansiReset} ${colors.text.ansi}Off-machine backup complete.${ansiReset}\n"
        else
          printf "${colors.yellow.ansi}⚠ Warning:${ansiReset} ${colors.text.ansi}Could not push backup to $remote_host. Local backup still exists.${ansiReset}\n"
        end

        set -l size (du -h "$archive" | cut -f1)
        printf "${colors.green.ansi}✓${ansiReset} ${colors.text.ansi}Backup saved:${ansiReset} ${colors.blue.ansi}%s${ansiReset} ${colors.text.ansi}(%s)${ansiReset}\n" (basename "$archive") "$size"

      case restore
        if test (count $argv) -lt 3
          printf "${colors.red.ansi}Error:${ansiReset} ${colors.text.ansi}Specify an archive name to restore. Use${ansiReset}\n"
          printf "  ${colors.green.ansi}mc-backup $server list${ansiReset} ${colors.text.ansi}to see available backups.${ansiReset}\n"
          return 1
        end
        set -l restore_from $argv[3]
        set -l restore_path "/tmp/$restore_from"
        set -l restored_remote 0

        # Try to pull from helios first
        printf "${colors.green.ansi}->${ansiReset} ${colors.peach.ansi}Fetching backup from${ansiReset} ${colors.blue.ansi}$remote_host${ansiReset} ${colors.text.ansi}...${ansiReset}\n"
        ${rsync} -az -e "${openssh} -i $ssh_key -o StrictHostKeyChecking=accept-new" "$remote_user@$remote_host:$remote_backup_dir$restore_from" "$restore_path"
        if test $status -eq 0
          set restored_remote 1
        else
          # Fall back to local copy
          set restore_path "$backup_dir/$restore_from"
          if not test -f "$restore_path"
            printf "${colors.red.ansi}Error:${ansiReset} ${colors.text.ansi}Archive${ansiReset} ${colors.blue.ansi}$restore_from${ansiReset} ${colors.text.ansi}not found on $remote_host or locally.${ansiReset}\n"
            return 1
          end
        end

        # Server must be stopped for restore
        if systemctl is-active --quiet "minecraft-$server"
          printf "${colors.red.ansi}Error:${ansiReset} ${colors.blue.ansi}$server${ansiReset} ${colors.text.ansi}is running. Stop it first:${ansiReset}\n"
          printf "  ${colors.green.ansi}mc-stop $server${ansiReset}\n"
          return 1
        end

        # Confirm — destructive operation
        printf "${colors.yellow.ansi}⚠ Warning:${ansiReset} ${colors.text.ansi}This will overwrite ALL data for${ansiReset}\n"
        printf "  ${colors.blue.ansi}$server${ansiReset}\n"
        printf "${colors.text.ansi}with the contents of:${ansiReset}\n"
        printf "  ${colors.blue.ansi}$restore_from${ansiReset}\n"
        printf "${colors.text.ansi}Proceed?${ansiReset} ${colors.peach.ansi}[y/N]${ansiReset} "
        read -l confirm
        if test "$confirm" != "y" -a "$confirm" != "Y"
          printf "${colors.text.ansi}Restore cancelled.${ansiReset}\n"
          return 0
        end

        printf "${colors.green.ansi}->${ansiReset} ${colors.peach.ansi}Restoring${ansiReset} ${colors.blue.ansi}$server${ansiReset} ${colors.text.ansi}from backup...${ansiReset}\n"

        # Ensure runtime dir exists, then wipe everything except the FIFO
        sudo mkdir -p "$src_dir"
        sudo find "$src_dir" -mindepth 1 -not -name '.stdin-fifo' -delete

        # Extract the backup
        sudo tar -xzf "$restore_path" -C "$src_dir"

        # Fix ownership
        sudo chown -R "minecraft-$server:minecraft-$server" "$src_dir"

        # Clean up temp file if we pulled from remote
        if test "$restored_remote" -eq 1
          rm -f "/tmp/$restore_from"
        end

        printf "${colors.green.ansi}✓${ansiReset} ${colors.text.ansi}Restore complete. Start the server:${ansiReset}\n"
        printf "  ${colors.green.ansi}mc-start $server${ansiReset}\n"

      case '*'
        printf "${colors.red.ansi}Error:${ansiReset} ${colors.text.ansi}Unknown flag '${ansiReset}${colors.peach.ansi}$flag${ansiReset}${colors.text.ansi}'. Use${ansiReset}\n"
        printf "  ${colors.green.ansi}mc-backup $server {list|run|restore}${ansiReset}\n"
        return 1
    end
  '';
}

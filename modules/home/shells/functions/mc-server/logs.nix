{ pkgs, lib }:

with lib;
with lib.custom;
with pkgs;

{
  mc-logs = ''
    if test (count $argv) -eq 0
      echo "Usage: mc-logs <server-name>"
      return 1
    end
    journalctl -u "minecraft-$argv[1]" -f --no-hostname | awk '
      BEGIN {
        b = "${hexToAnsi colors.blue.hex}"
        y = "${hexToAnsi colors.yellow.hex}"
        p = "${hexToAnsi colors.peach.hex}"
        r = "${hexToAnsi colors.red.hex}"
        g = "${hexToAnsi colors.green.hex}"
        w = "${hexToAnsi colors.text.hex}"
        n = "${ansiReset}"
      }
      {
        if (match($0, /^[A-Z][a-z]+ [0-9]+ [0-9:]+/)) {
          date = substr($0, RSTART, RLENGTH)
          rest = substr($0, RLENGTH + 1)

          # Strip " hash-wrapper[PID]: "
          sub(/^ [^ ]+\[[0-9]+\]: /, "", rest)

          # Strip Minecraft timestamp [HH:MM:SS]
          sub(/^\[[0-9:]+\] /, "", rest)

          # Extract level tag [Thread/LEVEL]
          level = ""
          msg = rest
          if (match(rest, /^\[[^]]+\]/)) {
            level = substr(rest, RSTART, RLENGTH)
            msg = substr(rest, RLENGTH + 1)
          }

          # Strip [modname]: tags from message
          gsub(/ \[[A-Za-z0-9._-]+\]: /, " ", msg)
          sub(/^ /, "", msg)

          # Pick level colour
          c = (level ~ /\/WARN\]/) ? p \
            : (level ~ /\/ERROR\]/) ? r \
            : (level ~ /\/FATAL\]/) ? r \
            : (level ~ /\/INFO\]/) ? y \
            : w

          # blue date:text | dynamic-colour [level] > | text-colour msg
          printf "%s%s%s%s:%s %s%s%s >%s %s%s%s\n", b, date, n, w, c, level, n, g, n, w, msg, n
        } else print
      }
    '
  '';

  mc-status = ''
    if test (count $argv) -eq 0
      printf "Usage: mc-status ${hexToAnsi colors.blue.hex}<server-name>${ansiReset}\n"
      return 1
    end
    set server $argv[1]
    if systemctl is-active --quiet "minecraft-$server"
      printf "${hexToAnsi colors.green.hex}$server is running.${ansiReset}\n"
    else
      printf "${hexToAnsi colors.yellow.hex}$server is stopped.${ansiReset}\n"
    end
    systemctl status --no-pager "minecraft-$server"
  '';

}

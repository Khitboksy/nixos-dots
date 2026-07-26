{ pkgs, lib }:

with lib;
with lib.custom;
with pkgs;

{
  mc-console = ''
    if test (count $argv) -eq 0
      printf "Usage: mc-console ${colors.helios.blue.ansi}<server-name>${ansiReset}\n"
      return 1
    end
    set server $argv[1]
    set fifo "/var/lib/minecraft-$server/.stdin-fifo"
    if not test -p "$fifo"
      printf "${colors.helios.red.ansi}Error:${ansiReset} Server ${colors.helios.blue.ansi}$server${ansiReset} is not running ${colors.helios.text.ansi}(start it with${ansiReset} ${colors.helios.green.ansi}mc-start $server${ansiReset}${colors.helios.text.ansi})${ansiReset}\n"
      return 1
    end
    printf "${colors.helios.text.ansi}Console for${ansiReset} ${colors.helios.blue.ansi}$server${ansiReset}${colors.helios.text.ansi}. Type${ansiReset} ${colors.helios.peach.ansi}exit${ansiReset}${colors.helios.text.ansi} to quit.${ansiReset}\n"
    printf "${colors.helios.text.ansi}(Run${ansiReset} ${colors.helios.green.ansi}mc-logs $server${ansiReset}${colors.helios.text.ansi} to see output live.)${ansiReset}\n"
    while true
      printf "${colors.helios.blue.ansi}%s${ansiReset} ${colors.helios.green.ansi}>${ansiReset} ${colors.helios.sapphire.ansi}" "$server"
      read cmd
      printf "${ansiReset}"
      if test "$cmd" = "exit"
        printf "${colors.helios.text.ansi}Console closed.${ansiReset}\n"
        break
      end
      echo "$cmd" > "$fifo"
    end
  '';
}

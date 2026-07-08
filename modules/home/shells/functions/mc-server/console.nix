{ pkgs, lib }:

with lib;
with lib.custom;
with pkgs;

{
  mc-console = ''
    if test (count $argv) -eq 0
      printf "Usage: mc-console ${colors.blue.ansi}<server-name>${ansiReset}\n"
      return 1
    end
    set server $argv[1]
    set fifo "/var/lib/minecraft-$server/.stdin-fifo"
    if not test -p "$fifo"
      printf "${colors.red.ansi}Error:${ansiReset} Server ${colors.blue.ansi}$server${ansiReset} is not running ${colors.text.ansi}(start it with${ansiReset} ${colors.green.ansi}mc-start $server${ansiReset}${colors.text.ansi})${ansiReset}\n"
      return 1
    end
    printf "${colors.text.ansi}Console for${ansiReset} ${colors.blue.ansi}$server${ansiReset}${colors.text.ansi}. Type${ansiReset} ${colors.peach.ansi}exit${ansiReset}${colors.text.ansi} to quit.${ansiReset}\n"
    printf "${colors.text.ansi}(Run${ansiReset} ${colors.green.ansi}mc-logs $server${ansiReset}${colors.text.ansi} to see output live.)${ansiReset}\n"
    while true
      printf "${colors.blue.ansi}%s${ansiReset} ${colors.green.ansi}>${ansiReset} ${colors.sapphire.ansi}" "$server"
      read cmd
      printf "${ansiReset}"
      if test "$cmd" = "exit"
        printf "${colors.text.ansi}Console closed.${ansiReset}\n"
        break
      end
      echo "$cmd" > "$fifo"
    end
  '';
}

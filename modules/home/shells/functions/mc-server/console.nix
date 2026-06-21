{ pkgs, lib }:

with lib;
with lib.custom;
with pkgs;

{
  mc-console = ''
    if test (count $argv) -eq 0
      printf "Usage: mc-console ${hexToAnsi colors.blue.hex}<server-name>${ansiReset}\n"
      return 1
    end
    set server $argv[1]
    set fifo "/var/lib/minecraft-$server/.stdin-fifo"
    if not test -p "$fifo"
      printf "${hexToAnsi colors.red.hex}Error:${ansiReset} Server ${hexToAnsi colors.blue.hex}$server${ansiReset} is not running ${hexToAnsi colors.text.hex}(start it with${ansiReset} ${hexToAnsi colors.green.hex}mc-start $server${ansiReset}${hexToAnsi colors.text.hex})${ansiReset}\n"
      return 1
    end
    printf "${hexToAnsi colors.text.hex}Console for${ansiReset} ${hexToAnsi colors.blue.hex}$server${ansiReset}${hexToAnsi colors.text.hex}. Type${ansiReset} ${hexToAnsi colors.peach.hex}exit${ansiReset}${hexToAnsi colors.text.hex} to quit.${ansiReset}\n"
    printf "${hexToAnsi colors.text.hex}(Run${ansiReset} ${hexToAnsi colors.green.hex}mc-logs $server${ansiReset}${hexToAnsi colors.text.hex} to see output live.)${ansiReset}\n"
    while true
      printf "${hexToAnsi colors.blue.hex}%s${ansiReset} ${hexToAnsi colors.green.hex}>${ansiReset} ${hexToAnsi colors.sapphire.hex}" "$server"
      read cmd
      printf "${ansiReset}"
      if test "$cmd" = "exit"
        printf "${hexToAnsi colors.text.hex}Console closed.${ansiReset}\n"
        break
      end
      echo "$cmd" > "$fifo"
    end
  '';
}

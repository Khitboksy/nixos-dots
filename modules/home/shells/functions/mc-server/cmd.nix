{ pkgs, lib }:

with lib;
with lib.custom;
with pkgs;

{
  mc-cmd = ''
    if test (count $argv) -lt 2
      echo "Usage: mc-cmd <server-name> <command...>"
      echo "  e.g. mc-cmd tekkit2 op friendname"
      echo "       mc-cmd tekkit2 say Restarting in 5 minutes"
      return 1
    end
    set server $argv[1]
    set cmd $argv[2..-1]
    set fifo "/var/lib/minecraft-$server/.stdin-fifo"
    if not test -p "$fifo"
      echo "Error: Server '$server' is not running (FIFO not found)"
      return 1
    end
    echo "$cmd" > "$fifo"
  '';
}

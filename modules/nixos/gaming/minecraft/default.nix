{
  lib,
  pkgs,
  config,
  ...
}:

with lib;
with lib.custom;

let
  cfg = config.gaming.minecraft;
in

{
  # Import individual server definitions from servers/*.nix
  # Each file declares options.gaming.minecraft.servers.<name>
  imports = [
    ./servers/tekkit2.nix
  ];

  options.gaming.minecraft = with types; {
    enable = mkBoolOpt false ''
      Enable Minecraft server infrastructure. Installs Java (JDK 8),
      which is required by most modded Minecraft servers (Forge 1.12.2,
      Tekkit, etc.). Enable individual server instances with:
      `gaming.minecraft.servers.<name>.enable = true`
    '';
  };

  config = mkIf cfg.enable {
    # Java 8 — baseline for modded MC; specific servers may add their own
    environment.systemPackages = [ pkgs.jdk8 ];
  };
}

{
  lib,
  zenith,
  pkgs,
  config,
  ...
}:

with zenith.lib';

let
  cfg = config.gaming.minecraft;
in

{
  # Import individual server definitions from servers/*.nix
  # Each file declares options.gaming.minecraft.servers.<name>
  imports = [
    ./servers/tekkit2.nix
  ];

  options.gaming.minecraft = with lib.types; {
    enable = mkBoolOpt false "Enable Vanilla and Modded Minecraft server infrastructure.";
  };

  config = lib.mkIf cfg.enable {
    # Server deps
    environment.systemPackages = with pkgs; [
      jdk8
      prismlauncher
    ];
  };
}

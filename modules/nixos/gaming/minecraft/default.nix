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
    enable = mkBoolOpt false "Enable Vanilla and Modded Minecraft server infrastructure.";
  };

  config = mkIf cfg.enable {
    # Server deps
    environment.systemPackages = with pkgs; [
      jdk8
      prismlauncher
    ];
  };
}

{
  lib,
  zenith,
  pkgs,
  config,
  ...
}:

with zenith.lib';

let
  cfg = config.apps.tools.macchina;
in

{
  options.apps.tools.macchina = with lib.types; {
    enable = mkBoolOpt false "Enable Macchina";
  };

  config = lib.mkIf cfg.enable {
    programs.macchina = {
      enable = true;
      package = pkgs.macchina;

      themes = (import ./themes/macchina-heliosTheme.nix) { inherit lib; };

      settings = {
        theme = "Helios";

        show = [
          "Distribution"
          "Kernel"
          "WindowManager"
          "Resolution"
          "Packages"
          "Terminal"
          "Processor"
          "Memory"
          "GPU"
          "DiskSpace"
        ];

        disks = [
          "/"
          "/home/helios"
          "/mnt/nix-data"
        ];
        disk_space_percentage = false;

        memory_percentage = false;
        physical_cores = true;
      };
    };

    home.file.".config/macchina/ascii/nixos_trans".source = ./ascii/nixos_trans_plain.txt;
  };
}

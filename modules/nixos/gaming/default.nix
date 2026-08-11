{
  lib,
  zenith,
  pkgs,
  config,
  ...
}:

with zenith.lib';

let
  cfg = config.gaming;
in

{

  options.gaming = with lib.types; {
    enable = mkBoolOpt false "Enable Gaming Module";
  };

  config = lib.mkIf cfg.enable {

    gaming = {
      apps.steam.enable = true;
    };
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      (lutris.override {
        extraLibraries = pkgs: [
          qt5.qtwayland
          wayland
        ];
      })

      protonup-qt
      r2modman
      clonehero
      ckan
    ];

    boot.kernelParams = [
      "preempt=full"
      "threadirqs"
      "skew-tick=1"
      "cpufreq.default_governor=performance"
    ];
  };
}
